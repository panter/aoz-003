require "application_system_test_case"

class AssignmentsTest < ApplicationSystemTestCase
  setup do
    @user = create :user, email: 'superadmin@example.com'
    login_as @user
    @client = create :client
    @volunteer = create :volunteer
  end

  test 'new assignment form with preselected fields' do
    visit new_assignment_path
    within '.assignment_client' do
      select(@client.contact.full_name, from: 'Client')
    end
    within '.assignment_volunteer' do
      select(@volunteer.contact.full_name, from: 'Volunteer')
    end
    click_button 'Create Assignment'
    assert page.has_text? 'Assignment was successfully created.'
    within '.table-striped' do
      assert page.has_text? 'Suggested'
      assert page.has_link? 'superadmin@example.com'
    end
  end

  test 'assign unassigned client (client side)' do
    visit clients_path
    click_link 'Need accompanying'
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
