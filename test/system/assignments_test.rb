require 'application_system_test_case'

class AssignmentsTest < ApplicationSystemTestCase
  setup do
    @user = create :user, email: 'superadmin@example.com'
    Assignment.with_deleted.map(&:really_destroy!)
    @client = create :client, user: @user
    @volunteer = create :volunteer, take_more_assignments: true
  end

  test 'new_assignment_form' do
    login_as @user
    visit new_assignment_path
    select @client.contact.full_name, from: 'Klient/in'
    select @volunteer.contact.full_name, from: 'Freiwillige'
    page.find('#assignment_period_start').click
    page.find('.month', text: 'Jan').click
    page.find_all('.day', exact_text: '1').first.click
    page.find_all('input[type="submit"]').first.click
    assert page.has_text? 'Begleitung wurde erfolgreich erstellt.'
    assert page.has_link? @volunteer.contact.full_name
    assert page.has_link? @client.contact.full_name
  end

  test 'assign unassigned client' do
    login_as @user
    visit volunteers_path
    click_link 'Klient/in suchen', match: :first
    click_link 'Klient/in suchen'
    click_link 'Begleitung erstellen'

    fill_in 'Einsatzbeginn', with: 2.days.ago.to_date
    click_button 'Begleitung erfassen', match: :first

    assert_text @client.contact.full_name
    assert_text @volunteer.contact.full_name

    visit client_path(@client)

    assert_text 'Aktiv'
    assert_text @volunteer

    visit volunteer_path(@volunteer)

    assert_text 'Aktiv'
    assert_text @client
  end

  test 'assign multiple clients' do
    login_as @user
    visit volunteers_path
    click_link 'Klient/in suchen', match: :first
    click_link 'Klient/in suchen'
    click_link 'Begleitung erstellen', match: :first

    fill_in 'Einsatzbeginn', with: 2.days.ago.to_date
    click_button 'Begleitung erfassen', match: :first

    assert_text @client.contact.full_name
    assert_text @volunteer.contact.full_name

    visit client_path(@client)

    assert_text 'Aktiv'
    assert_text @volunteer

    visit volunteer_path(@volunteer)

    assert_text 'Aktiv'
    assert_text @client

    another_client = create :client
    visit volunteer_path(@volunteer)

    click_link 'Zusätzliche/n Klient/in suchen'
    click_link 'Begleitung erstellen', match: :first

    fill_in 'Einsatzbeginn', with: 3.days.ago.to_date
    click_button 'Begleitung erfassen', match: :first

    assert_text another_client.contact.full_name
    assert_text @volunteer.contact.full_name

    visit client_path(another_client)

    assert_text 'Aktiv'
    assert_text @volunteer

    visit volunteer_path(@volunteer)
    assert_text @client
    assert_text another_client
  end

  test 'volunteer cannot see new/edit assignment buttons' do
    create :assignment, volunteer: @volunteer
    login_as @volunteer.user
    visit volunteer_path(@volunteer)

    refute_link 'Begleitung erfassen'

    within '.assignments-table, .group-assignments-table' do
      refute_link 'Bearbeiten'
    end
  end

  test 'assignments_print_view_is_not_paginated' do
    Assignment.with_deleted.map(&:really_destroy!)
    45.times { create :assignment }
    login_as @user
    visit assignments_url(print: true)
    assert_equal Assignment.count, find_all('tbody tr').size
  end

  test 'saves assigment before download or print' do
    assignment = create :assignment, volunteer: @volunteer

    login_as @user

    visit edit_volunteer_assignment_url(volunteer_id: @volunteer.id, id: assignment.id)
    fill_in 'Bemerkungen', with: 'test'
    page.find_all('.autosave-button a').first.click

    assert_equal 'test', page.find_all('#assignment_comments').first.value
    assert_equal 'test', assignment.reload.comments
  end
end
