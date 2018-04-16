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
    select @client.contact.full_name, from: 'Klient/in'
    select @volunteer.contact.full_name, from: 'Freiwillige'
    page.find('#assignment_period_start').click
    page.find('.month', text: 'Jan').click
    page.find_all('.day', exact_text: '1').first.click
    click_button 'Begleitung erfassen'
    assert page.has_text? 'Begleitung wurde erfolgreich erstellt.'
    assert page.has_link? @volunteer.contact.full_name
    assert page.has_link? @client.contact.full_name
  end

  # TODO: Flappy test
  # test 'assign unassigned client' do
  #   login_as @user
  #   visit volunteers_path
  #   click_link 'Klienten suchen'
  #   click_link 'Klient/in finden'

  #   wait_for_ajax
  #   click_link 'Reservieren'

  #   fill_in 'Einsatzbeginn', with: 2.days.ago.to_date
  #   click_button 'Begleitung erfassen'

  #   assert_text @client.contact.full_name
  #   assert_text @volunteer.contact.full_name

  #   visit client_path(@client)

  #   assert_text 'Aktiv'
  #   assert_text @volunteer

  #   visit volunteer_path(@volunteer)

  #   assert_text 'Aktiv'
  #   assert_text @client
  # end

  test 'creating_a_pdf_with_a_user_that_has_no_profile_will_not_crash' do
    user = create :user, :without_profile
    refute user.profile.present?

    login_as user
    visit new_assignment_path
    select @client.contact.full_name, from: 'Klient/in'
    select @volunteer.contact.full_name, from: 'Freiwillige'
    page.find('#assignment_period_start').click
    page.find('.month', text: 'Jan').click
    page.find_all('.day', exact_text: '1').first.click
    click_button 'Begleitung erfassen'

    get assignments_url(@volunteer, format: :pdf)
    assert page.has_text? @client.contact.last_name
  end

  test 'volunteer can not see new assignment button' do
    login_as @volunteer.user
    visit volunteer_path(@volunteer)
    refute page.has_link? 'Begleitung erfassen'
  end

  test 'assignments_print_view_is_not_paginated' do
    Assignment.with_deleted.map(&:really_destroy!)
    45.times { create :assignment }
    login_as @user
    visit assignments_url(print: true)
    assert_equal Assignment.count, find_all('tbody tr').size
  end
end
