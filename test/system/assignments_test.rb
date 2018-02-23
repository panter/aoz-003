require 'application_system_test_case'

class AssignmentsTest < ApplicationSystemTestCase
  setup do
    @user = create :user, email: 'superadmin@example.com'
    Assignment.with_deleted.map(&:really_destroy!)
    @client = create :client, user: @user
    @volunteer = create :volunteer_with_user, take_more_assignments: true
  end

  test 'new_assignment_form' do
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
      assert page.has_link? @volunteer.contact.full_name
      assert page.has_link? @client.contact.full_name
    end
  end

  # Travis GFYS
  # test 'assign unassigned client - volunteer side' do
  #   login_as @user
  #   visit volunteers_path
  #   click_link 'Looking for clients'
  #   click_link 'Find client'
  #   page.find('a', text: 'Reserve').click
  #   visit current_url
  #   page.refresh
  #   sleep 5
  #   click_button 'Create Assignment'
  #   assignment = Assignment.last
  #   assignment.period_start = 2.days.ago.to_date
  #   assignment.save!
  #   assert page.has_text? @client.contact.full_name
  #   assert page.has_text? @volunteer.contact.full_name
  #   visit client_path(@client)
  #   assert page.has_text? 'Reserved'
  #   visit volunteer_path(@volunteer)
  #   assert page.has_text? 'Active'
  # end

  test 'creating_a_pdf_with_a_user_that_has_no_profile_will_not_crash' do
    login_as @user
    user = create :user, :without_profile
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
    assert page.has_text? @client.contact.last_name
  end

  test 'volunteer can not see new assignment button' do
    login_as @volunteer.user
    visit volunteer_path(@volunteer)
    refute page.has_link? 'New Assignment'
  end

  test 'assignments_print_view_is_not_paginated' do
    Assignment.with_deleted.map(&:really_destroy!)
    45.times { create :assignment }
    login_as @user
    visit assignments_url(print: true)
    assert_equal Assignment.count, find_all('tbody tr').size
  end
end
