require 'application_system_test_case'

class BillingExpensesTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @volunteer = create :volunteer
    @client = create :client
    assignment = create :assignment, volunteer: @volunteer, client: @client
    login_as @superadmin
  end

  test 'superadmin can create a billing expense' do
    visit volunteer_path(@volunteer)
    click_link 'New Billing expense'
    select @client.contact.full_name, from: 'Assignment'
    select '50', from: 'Amount'
    click_button 'Create Billing expense'
    assert page.has_text? 'Billing expense was successfully created.'
  end
end
