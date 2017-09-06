require 'application_system_test_case'

class BillingExpensesTest < ApplicationSystemTestCase
  def setup
    superadmin = create :user
    @volunteer = create :volunteer
    assignment = create :assignment, volunteer: @volunteer
    create :hour, volunteer: @volunteer, assignment: assignment
    login_as superadmin
    visit volunteer_path(@volunteer)
    click_link 'New Billing expense'
    click_button 'Create Billing expense'
  end

  test 'superadmin can create a billing expense' do
    assert page.has_text? 'Billing expense was successfully created.'
  end

  test 'no duplicate billing expenses' do
    click_link 'New Billing expense'
    click_button 'Create Billing expense'
    assert_no_difference 'BillingExpense.count' do
      click_link 'New Billing expense'
      click_button 'Create Billing expense'
      assert page.has_text? 'This billing expense was already created'
    end
  end
end
