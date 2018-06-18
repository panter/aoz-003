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

    fill_in 'Einsatzbeginn', with: I18n.l(2.days.ago.to_date)
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

    fill_in 'Einsatzbeginn', with: I18n.l(2.days.ago.to_date)
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

    fill_in 'Einsatzbeginn', with: I18n.l(3.days.ago.to_date)
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

  test 'social_worker can show and download assigment pdf' do
    use_rack_driver

    social_worker = create :social_worker
    client = create :client, user: social_worker
    assignment = create :assignment, client: client
    another_assignment = create :assignment

    # generate PDFs first via superadmin
    login_as @user

    visit edit_assignment_path(assignment)
    click_button 'Begleitung aktualisieren', match: :first
    visit edit_assignment_path(another_assignment)
    click_button 'Begleitung aktualisieren', match: :first
    visit client_path(client)
    assert page.has_link? 'Herunterladen'
    visit client_path(another_assignment.client)
    assert page.has_link? 'Herunterladen'

    # check show page and pdf download via social worker
    login_as social_worker

    visit client_path(another_assignment.client)
    refute page.has_link? 'Anzeigen'
    refute page.has_link? 'Herunterladen'

    visit client_path(client)
    assert page.has_link? 'Anzeigen'
    assert page.has_link? 'Herunterladen'

    click_link 'Anzeigen'
    assert page.has_text? 'Vereinbarung zwischen AOZ, Freiwilligen und Begleiteten'
    assert page.has_text? "#{assignment.client.contact.primary_email}"
    assert page.has_text? "#{assignment.volunteer.contact.primary_email}"
    assert page.has_text? "#{assignment.involved_authority_contact.primary_email}"

    visit client_path(client)
    click_link 'Herunterladen'
    pdf = load_pdf(page.body)
    assert_equal 1, pdf.page_count
    assert_match /#{assignment.client.contact.primary_email}/, pdf.pages.first.text
    assert_match /#{assignment.volunteer.contact.primary_email}/, pdf.pages.first.text
    assert_match /#{assignment.involved_authority_contact.primary_email}/, pdf.pages.first.text
  end

  test 'assignments_print_view_is_not_paginated' do
    Assignment.with_deleted.map(&:really_destroy!)
    45.times { create :assignment }
    login_as @user
    visit assignments_url(print: true)
    assert_equal Assignment.count, find_all('tbody tr').size
  end

  test 'creates/updates assignment PDF when requested' do
    use_rack_driver

    pdf_date = 1.week.ago
    travel_to pdf_date

    assignment = create :assignment, volunteer: @volunteer
    login_as @user
    visit assignments_path

    refute_link 'Herunterladen'

    # create initial PDF

    click_on 'Bearbeiten'
    fill_in 'Wie oft?', with: 'daily'

    assert_field 'Vereinbarung erzeugen', checked: true

    click_on 'Begleitung aktualisieren', match: :first

    assert_text 'Begleitung wurde erfolgreich geändert.'
    assert_field 'Vereinbarung überschreiben', checked: false

    click_on 'Herunterladen', match: :first
    pdf = load_pdf(page.body)

    assert_equal 1, pdf.page_count
    assert_match(/Ort, Datum: +Zürich, #{I18n.l pdf_date.to_date}/, pdf.pages.first.text)
    assert_match(/Wie oft\? +daily/, pdf.pages.first.text)

    # changing a field doesn't automatically update the PDF

    visit edit_assignment_path(assignment)
    fill_in 'Wie oft?', with: 'weekly'
    click_on 'Begleitung aktualisieren', match: :first

    assert_text 'Begleitung wurde erfolgreich geändert.'

    click_on 'Herunterladen', match: :first
    pdf = load_pdf(page.body)

    assert_match(/Wie oft\? +daily/, pdf.pages.first.text)

    # request to update the PDF

    pdf_date = 3.days.from_now
    travel_to pdf_date

    visit edit_assignment_path(assignment)
    check 'Vereinbarung überschreiben'
    click_on 'Begleitung aktualisieren', match: :first

    assert_text 'Begleitung wurde erfolgreich geändert.'

    click_on 'Herunterladen', match: :first
    pdf = load_pdf(page.body)

    assert_match(/Ort, Datum: +Zürich, #{I18n.l pdf_date.to_date}/, pdf.pages.first.text)
    assert_match(/Wie oft\? +weekly/, pdf.pages.first.text)

    # make sure the download link is displayed on the index as well

    visit assignments_path

    assert_link 'Herunterladen', count: 1

    # make sure the HTML view also displays the PDF creation date

    click_on 'Anzeigen'

    assert_text "Ort, Datum:Zürich, #{I18n.l pdf_date.to_date}"
  end
end
