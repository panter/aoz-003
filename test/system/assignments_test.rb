require 'application_system_test_case'

class AssignmentsTest < ApplicationSystemTestCase
  setup do
    @user = create :user, email: 'superadmin@example.com'
    login_as @user
    Assignment.with_deleted.map(&:really_destroy!)
    @volunteer_user = create :user, role: 'volunteer'
    @client = create :client, user: @user
    @volunteer = create :volunteer, state: Volunteer::ACTIVE_FURTHER, user: @volunteer_user
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

  # test 'assign unassigned client - client side' do
  #   visit clients_path
  #   click_link 'Need accompanying'
  #   click_link 'Find volunteer'
  #   click_link 'Reserve'
  #   click_button 'Create Assignment'
  #   assert page.has_text? @client.contact.full_name
  #   assert page.has_text? @volunteer.contact.full_name
  #   visit client_path(@client)
  #   assert page.has_text? 'Reserved'
  #   visit volunteer_path(@volunteer)
  #   assert page.has_text? 'Active'
  # end

  # test 'assign unassigned client - volunteer side' do
  #   # FIXME: If we follow the same logic with the previous test
  #   # visit volunteers_path
  #   # click_link 'Looking for clients'
  #   # the test fails to find the 'Find client' link
  #   # as it doesn't actually click the 'Looking for clients link'
  #   visit seeking_clients_volunteers_path
  #   click_link 'Find client'
  #   click_link 'Reserve'
  #   click_button 'Create Assignment'
  #   assert page.has_text? @client.contact.full_name
  #   assert page.has_text? @volunteer.contact.full_name
  #   visit client_path(@client)
  #   assert page.has_text? 'Reserved'
  #   visit volunteer_path(@volunteer)
  #   assert page.has_text? 'Active'
  # end

  test 'no duplicate assignments' do
    create :assignment, client: @client, volunteer: @volunteer, creator: @user
    assert_no_difference 'Assignment.count' do
      visit new_assignment_path
      select(@client.contact.full_name, from: 'Client')
      select(@volunteer.contact.full_name, from: 'Volunteer')
      click_button 'Create Assignment'
      assert page.has_text? 'Assignment already exists.'
    end
  end

  test 'creating a pdf with a user that has no profile will not crash' do
    user = create :user, profile: nil
    refute user.profile.present?

    login_as user
    visit new_assignment_path
    within '.assignment_client' do
      select(@client.contact.full_name, from: 'Client')
    end
    within '.assignment_volunteer' do
      select(@volunteer.contact.full_name, from: 'Volunteer')
    end
    click_button 'Create Assignment'
    within '.table-striped' do
      click_link 'Show'
    end
    assert page.has_text? @client.contact.full_name
  end
end
