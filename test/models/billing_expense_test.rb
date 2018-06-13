require 'test_helper'

class BillingExpenseTest < ActiveSupport::TestCase
  test 'amount_for' do
    assert_equal 150, BillingExpense.amount_for(999)
    assert_equal 150, BillingExpense.amount_for(51)

    assert_equal 100, BillingExpense.amount_for(50)
    assert_equal 100, BillingExpense.amount_for(26)

    assert_equal 50, BillingExpense.amount_for(25)
    assert_equal 50, BillingExpense.amount_for(1)
    assert_equal 50, BillingExpense.amount_for(0.1)

    assert_equal 0, BillingExpense.amount_for(0)
    assert_equal 0, BillingExpense.amount_for(-999)
  end

  test 'create_for!' do # rubocop:disable Metrics/BlockLength
    volunteer1 = create :volunteer, bank: 'Bank 1'
    hour1a = create :hour, volunteer: volunteer1
    hour1b = create :hour, volunteer: volunteer1
    hour1c = create :hour, volunteer: volunteer1
    create :billing_expense, volunteer: volunteer1, hours: [hour1c]

    volunteer2 = create :volunteer, bank: 'Bank 2'
    hour2 = create :hour, volunteer: volunteer2, hours: 75

    creator = create :user

    assert_equal 1, BillingExpense.count
    assert_equal 1, volunteer1.billing_expenses.count
    assert_equal 0, volunteer2.billing_expenses.count

    BillingExpense.create_for!(Volunteer.with_billable_hours, creator)

    volunteer1.reload
    volunteer2.reload
    hour1a.reload
    hour1b.reload
    hour1c.reload
    hour2.reload

    billing_expense1 = volunteer1.billing_expenses.reorder(:id).last
    billing_expense2 = volunteer2.billing_expenses.reorder(:id).last

    assert_equal 3, BillingExpense.count
    assert_equal 2, volunteer1.billing_expenses.count
    assert_equal 1, volunteer2.billing_expenses.count

    assert_equal creator, billing_expense1.user
    assert_equal creator, billing_expense2.user

    assert_equal 50, billing_expense1.amount
    assert_equal 150, billing_expense2.amount

    assert_equal [hour1a, hour1b], billing_expense1.hours.reorder(:id)
    assert_equal [hour2], billing_expense2.hours

    assert_equal 'Bank 1', billing_expense1.bank
    assert_equal volunteer1.iban, billing_expense1.iban

    assert_equal 'Bank 2', billing_expense2.bank
    assert_equal volunteer2.iban, billing_expense2.iban

    assert_equal creator, hour1a.reload.reviewer
    assert_equal creator, hour1b.reload.reviewer
    refute_equal creator, hour1c.reload.reviewer
  end

  test 'generate_periods without hours' do
    periods = BillingExpense.generate_periods
    now = Time.zone.now

    if now > now.beginning_of_year - 1.month + BillingExpense::PERIOD
      value = "#{now.year}-06-01"
      text = "Juni #{now.year} - November #{now.year}"
    else
      value = "#{now.year}-12-01"
      text = "Dezember #{now.year} - Mai #{now.year}"
    end

    assert_equal [{ q: :period, value: value, text: text }], periods
  end

  test 'generate_periods with hours' do
    hour1 = create :hour, meeting_date: '2014-02-03'
    hour2 = create :hour, meeting_date: '2015-06-30'
    create :hour, meeting_date: '2017-06-30'
    create :billing_expense, hours: [hour1, hour2]

    periods = BillingExpense.generate_periods

    assert_equal [
      { q: :period, value: '2015-06-01', text: 'Juni 2015 - November 2015' },
      { q: :period, value: '2014-12-01', text: 'Dezember 2014 - Mai 2015' },
      { q: :period, value: '2014-06-01', text: 'Juni 2014 - November 2014' },
      { q: :period, value: '2013-12-01', text: 'Dezember 2013 - Mai 2014' }
    ], periods
  end

  test 'period scope' do
    date = Time.zone.now.beginning_of_year

    billing_expense1 = create :billing_expense,
      hours: [create(:hour, meeting_date: date + 1.week)]

    billing_expense2 = create :billing_expense,
      hours: [
        create(:hour, meeting_date: date + 1.week),
        create(:hour, meeting_date: date - 1.week)
      ]

    _billing_expense3 = create :billing_expense,
      hours: [create(:hour, meeting_date: date - 1.week)]

    assert_equal [billing_expense1, billing_expense2], BillingExpense.period(date).reorder(:id)
  end

  test 'amount can be overwriten' do
    volunteer = create :volunteer
    hour1 = create :hour, volunteer: volunteer, hours: 1
    hour2 = create :hour, volunteer: volunteer, hours: 2
    hour3 = create :hour, volunteer: volunteer, hours: 3

    billing_expense = create :billing_expense, volunteer: volunteer, hours: [hour1, hour2, hour3]
    assert_equal billing_expense.final_amount, billing_expense.amount

    billing_expense.update overwritten_amount: 200
    billing_expense.reload
    assert_equal billing_expense.final_amount, 200

    billing_expense.update overwritten_amount: ''
    billing_expense.reload
    assert_equal billing_expense.final_amount, billing_expense.amount
  end

  test 'edited amounts are sortable' do
    volunteer1 = create :volunteer
    hour1 = create :hour, volunteer: volunteer1, hours: 1
    hour2 = create :hour, volunteer: volunteer1, hours: 2

    volunteer2 = create :volunteer
    hour3 = create :hour, volunteer: volunteer2, hours: 20
    hour4 = create :hour, volunteer: volunteer2, hours: 15

    billing_expense1 = create :billing_expense, volunteer: volunteer1, hours: [hour1, hour2]
    billing_expense2 = create :billing_expense, volunteer: volunteer2, hours: [hour3, hour4]

    assert_equal 50, billing_expense1.final_amount
    assert_equal 100, billing_expense2.final_amount

    billing_expense2.update overwritten_amount: 25

    sorted_by_asc =  [billing_expense2, billing_expense1]
    sorted_by_desc = sorted_by_asc.reverse

    BillingExpense.unscoped.sort_by_final_amount_asc.each_with_index do |billing_expense, i|
      assert_equal sorted_by_asc[i], billing_expense
    end

    BillingExpense.unscoped.sort_by_final_amount_desc.each_with_index do |billing_expense, i|
      assert_equal sorted_by_desc[i], billing_expense
    end
  end
end
