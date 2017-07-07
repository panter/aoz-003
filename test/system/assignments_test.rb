require "application_system_test_case"

class AssignmentsTest < ApplicationSystemTestCase
  setup do
    @user = create :user, :with_profile, email: 'superadmin@example.com'
    login_as @user
    @client = create :client
    @volunteer = create :volunteer
    visit clients_path
  end

  test 'assign unassigned client' do
    click_link 'Without Assignment'
    click_link 'Find volunteer'
    click_link 'Reserve'
    click_button 'Create Assignment'
    assert page.has_text? @client.contact.full_name
    assert page.has_text? @volunteer.contact.full_name
    visit client_path(@client)
    assert page.has_text? 'Reserved'
    visit volunteer_path(@volunteer)
    assert page.has_text? 'Active'
  end
end
