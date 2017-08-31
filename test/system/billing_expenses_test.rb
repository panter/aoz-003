require 'application_system_test_case'

class BillingExpensesTest < ApplicationSystemTestCase
  def setup
    @user_volunteer1 = create :user, role: 'volunteer', email: 'volunteer1@example.com'
    @volunteer1 = @user_volunteer1.volunteer = create :volunteer
    @client1 = create :client
    @assignment1 = create :assignment, volunteer: @volunteer1, client: @client1
    login_as @user_volunteer1
    visit root_url
    click_link 'volunteer1@example.com'
    click_link 'Show profile'
  end

  test 'volunteer can create a billing expense' do
    click_link 'New Billing expense'
    select @client1.contact.full_name, from: 'Assignment'
    select '50', from: 'Amount'
    click_button 'Create Billing expense'
    assert page.has_text? 'Billing expense was successfully created.'
  end

  test 'volunteer can see only her billing expenses' do
    @volunteer2 = create :volunteer
    @client2 = create :client
    @assignment2 = create :assignment, volunteer: @volunteer2, client: @client2
    create :billing_expense, assignment: @assignment2, volunteer: @volunteer2
    click_link 'Billing expense index'
    assert page.has_text? @client1.contact.full_name
    refute page.has_text? @client2.contact.full_name
    visit volunteer_billing_expenses_path(@volunteer2)
    assert page.has_text? 'You are not authorized to perform this action.'
    refute page.has_text? @client2.contact.full_name
  end
end
