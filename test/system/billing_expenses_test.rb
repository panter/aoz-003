require 'application_system_test_case'

class BillingExpensesTest < ApplicationSystemTestCase
  def setup
    superadmin = create :user
    @volunteer = create :volunteer
    @assignment = create :assignment, volunteer: @volunteer, period_start: 9.months.ago
    @hour1 = create :hour, volunteer: @volunteer, hourable: @assignment, hours: '2', minutes: '30'
    @group_offer = create :group_offer
    @group_assignment = create :group_assignment, volunteer: @volunteer, period_start: 9.months.ago
    @hour2 = create :hour, hourable: @group_offer, volunteer: @volunteer, hours: '3', minutes: '30'

    login_as superadmin
    visit volunteer_path(@volunteer)
    click_button 'Create Billing expense'
  end

  test 'superadmin can create a billing expense' do
    assert page.has_text? 'Billing expense was successfully created.'
  end

  test 'created billing expenses collects hours from assignment and group offer' do
    within '.table-responsive' do
      assert_equal 6, @volunteer.hours.total_hours
      assert_equal 50, @volunteer.billing_expenses.last.amount
    end
  end

  test 'no duplicate billing expenses' do
    click_button 'Create Billing expense'
    visit volunteer_path(@volunteer)
    assert_no_difference 'BillingExpense.count' do
      click_button 'Create Billing expense'
      assert page.has_text? 'There are no billable hours for this volunteer'
    end
  end

  test 'created billing expenses has needed fields' do
    within '.table-responsive' do
      assert page.has_link? @volunteer.contact.full_name
      assert page.has_text? @volunteer.contact.full_address
      click_link 'Show'
    end
    assert page.has_text? 'Spesenauszahlung an'
    assert page.has_text? 'Kostenstelle'
    assert page.has_text? '4182'
    assert page.has_text? 'Konto'
    assert page.has_text? '4621'
    assert page.has_text? 'zu überweisender Betrag'
    assert page.has_text? 'Name'
    assert page.has_text? 'Vorname'
    assert page.has_text? 'Strasse'
    assert page.has_text? 'PLZ / Ort'
    assert page.has_text? 'Bank / IBAN'
  end

  test 'volunteer that has only group offers can create billing expenses' do
    volunteer = create :volunteer
    group_offer = create :group_offer, volunteers: [volunteer]
    volunteer.group_assignments.last.update(period_start: 2.months.ago)
    create :hour, hourable: group_offer, volunteer: volunteer, hours: '3', minutes: '30'

    visit volunteer_path(volunteer)
    click_button 'Create Billing expense'
    assert page.has_text? 'Billing expense was successfully created.'
  end
end
