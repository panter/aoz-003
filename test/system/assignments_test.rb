require 'application_system_test_case'

class AssignmentsTest < ApplicationSystemTestCase
  setup do
    @user = create :user, email: 'superadmin@example.com'
    Assignment.with_deleted.map(&:really_destroy!)
    @volunteer_user = create :user, role: 'volunteer'
    @client = create :client, user: @user
    @volunteer = create :volunteer, user: @volunteer_user, take_more_assignments: true
  end

  test 'new assignment form with preselected fields' do
    login_as @user
    visit new_assignment_path
    select @client.contact.full_name, from: 'Client'
    select @volunteer.contact.full_name, from: 'Volunteer'
    page.find('#assignment_period_start').click
    page.find('.month', text: 'Jan').click
    page.find_all('.day', exact_text: '1').first.click
    click_button 'Create Assignment'
    assert page.has_text? 'Assignment was successfully created.'
    within '.table-striped' do
      assert page.has_text? 'Suggested'
      assert page.has_link? @volunteer.contact.full_name
      assert page.has_link? @client.contact.full_name
    end
  end

  test 'assign unassigned client - client side' do
    login_as @user
    visit clients_path
    first(:link, 'Need accompanying').click
    click_link 'Find volunteer'
    click_link 'Reserve'
    page.find('#assignment_period_start').click
    page.find('.month', text: 'Jan').click
    page.find_all('.day', exact_text: '1').first.click
    click_button 'Create Assignment'
    assert page.has_text? @client.contact.full_name
    assert page.has_text? @volunteer.contact.full_name
    visit client_path(@client)
    assert page.has_text? 'Reserved'
    visit volunteer_path(@volunteer)
    assert page.has_text? 'Active'
  end

  test 'assign unassigned client - volunteer side' do
    login_as @user
    visit seeking_clients_volunteers_path
    click_link 'Find client'
    click_link 'Reserve'
    page.find('#assignment_period_start').click
    page.find('.month', text: 'Jan').click
    page.find_all('.day', exact_text: '1').first.click
    click_button 'Create Assignment'
    assert page.has_text? @client.contact.full_name
    assert page.has_text? @volunteer.contact.full_name
    visit client_path(@client)
    assert page.has_text? 'Reserved'
    visit volunteer_path(@volunteer)
    assert page.has_text? 'Active'
  end

  test 'creating a pdf with a user that has no profile will not crash' do
    login_as @user
    user = create :user, profile: nil
    refute user.profile.present?

    login_as user
    visit new_assignment_path
    select @client.contact.full_name, from: 'Client'
    select @volunteer.contact.full_name, from: 'Volunteer'
    page.find('#assignment_period_start').click
    page.find('.month', text: 'Jan').click
    page.find_all('.day', exact_text: '1').first.click
    click_button 'Create Assignment'
    within '.table-striped' do
      click_link 'Show'
    end
    assert page.has_text? @client.contact.full_name
  end

  test 'volunteer can not see new assignment button' do
    login_as @volunteer_user
    visit volunteer_path(@volunteer)
    refute page.has_link? 'New Assignment'
  end
end
