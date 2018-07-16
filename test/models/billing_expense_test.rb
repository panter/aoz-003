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

  test 'create_for' do # rubocop:disable Metrics/BlockLength
    travel_to tz_parse('2017-07-12')
    volunteer1 = create :volunteer_with_user, bank: 'Bank 1'
    other_creator = volunteer1.registrar
    assignment1 = create :assignment, volunteer: volunteer1, creator: other_creator
    hour1a = create :hour, volunteer: volunteer1, meeting_date: tz_parse('2017-04-02'), hourable: assignment1
    hour1b = create :hour, volunteer: volunteer1, meeting_date: tz_parse('2017-05-12'), hourable: assignment1
    hour1c = create :hour, volunteer: volunteer1, meeting_date: tz_parse('2017-01-18'), hourable: assignment1
    create :billing_expense, volunteer: volunteer1, hours: [hour1c], user: other_creator


    volunteer2 = create :volunteer, bank: 'Bank 2'
    creator = volunteer2.registrar
    group_assignment1 = create :group_assignment, volunteer: volunteer2, creator: creator
    hour2 = create :hour, volunteer: volunteer2, hours: 75, meeting_date: tz_parse('2017-03-22'), hourable: group_assignment1

    assert_equal 1, BillingExpense.count
    assert_equal 1, volunteer1.billing_expenses.count
    assert_equal 0, volunteer2.billing_expenses.count
    BillingExpense.create_for!(Volunteer.with_billable_hours('2016-12-01'), creator)

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

    assert_includes billing_expense1.hours, hour1a
    assert_includes billing_expense1.hours, hour1b
    assert_includes billing_expense2.hours, hour2

    assert_equal 'Bank 1', billing_expense1.bank
    assert_equal volunteer1.iban, billing_expense1.iban

    assert_equal 'Bank 2', billing_expense2.bank
    assert_equal volunteer2.iban, billing_expense2.iban

    assert_equal creator, hour1a.reviewer
    assert_equal creator, hour1b.reviewer
    refute_equal creator, hour1c.reviewer
  end

  test 'generate_semester_filters_without_hours' do
    semesters = BillingExpense.generate_semester_filters
    now = Time.zone.now
    if (6..11).cover? now.month
      value = "#{now.year}-06-01"
      text = "2. Semester #{now.year}"
    else
      start_year = now.month == 12 ? now.year : now.year - 1
      value = "#{start_year}-12-01"
      text = "1. Semester #{start_year + 1}"
    end

    assert_equal [{ q: :semester, value: value, text: text }], semesters
  end

  test 'generate_semester_filters_with_hours' do
    travel_to tz_parse('2018-06-30')
    create :hour, meeting_date: '2017-06-30'
    create :hour, meeting_date: '2012-06-30'
    create :billing_expense, hours: [create(:hour, meeting_date: '2014-02-03'),
                                     create(:hour, meeting_date: '2015-06-30')]

    semesters = BillingExpense.generate_semester_filters

    assert_equal [
      { q: :semester, value: '2015-06-01', text: '2. Semester 2015' },
      { q: :semester, value: '2013-12-01', text: '1. Semester 2014' }
    ], semesters

    semesters = BillingExpense.generate_semester_filters(:billable)

    assert_equal [
      { q: :semester, value: '2017-06-01', text: '2. Semester 2017' },
      { q: :semester, value: '2012-06-01', text: '2. Semester 2012' }
    ], semesters
  end

  test 'semester_scope' do
    billing_expense1 = create :billing_expense,
      hours: [create(:hour, meeting_date: tz_parse('2017-01-12'))]

    billing_expense2 = create :billing_expense,
      hours: [
        create(:hour, meeting_date: tz_parse('2017-02-01')),
        create(:hour, meeting_date: tz_parse('2017-05-12'))
      ]

    _billing_expense3 = create :billing_expense,
      hours: [create(:hour, meeting_date: tz_parse('2016-11-30'))]

    assert_includes BillingExpense.semester('2016-12-01'), billing_expense1
    assert_includes BillingExpense.semester('2016-12-01'), billing_expense2
  end

  test 'amount_can_be_overwriten' do
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

  test 'edited_amounts_are_sortable' do
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
