require 'application_system_test_case'

class ClientsTest < ApplicationSystemTestCase
  setup do
    @superadmin = create :user, email: 'superadmin@example.com'
    @department_manager = create :department_manager, email: 'department@example.com'
    @social_worker = create :social_worker
  end

  test 'new client form' do
    login_as @superadmin
    visit new_client_path

    fill_in 'Vorname', with: 'asdf'
    fill_in 'Nachname', with: 'asdf'
    within '.client_birth_year' do
      select('1995', from: 'Geburtsdatum')
    end
    select('Frau', from: 'Anrede')
    select('Aruba', from: 'Nationalität')
    fill_in 'Einreisedatum', with: 'Sept. 2015'
    choose('client_permit_b')
    fill_in 'Strasse', with: 'Sihlstrasse 131'
    fill_in 'PLZ', with: '8002'
    fill_in 'Ort', with: 'Zürich'
    fill_in 'Mailadresse', with: 'gurke@gurkenmail.com'
    fill_in 'Telefonnummer', with: '0123456789', match: :first
    fill_in 'Telefonnummer 2', with: '0123456789'
    within '#languages' do
      choose('Gut')
    end
    click_on('Sprache hinzufügen')
    select('Albanisch', from: 'Sprache')
    select('Mittel', from: 'Niveau')
    click_on('Verwandte hinzufügen')
    within '#relatives' do
      fill_in 'Vorname', with: 'asdf'
      fill_in 'Nachname', with: 'asdf'
      select('2001', from: 'Geburtsdatum')
      select('Onkel', from: 'Verwandtschaftsbeziehung')
    end
    fill_in 'Inhalte der Begleitung', with: 'asdfasdf'
    select('egal', from: 'Geschlecht Freiwillige/r')
    select('36 - 50', from: 'Alter Freiwillige/r')
    fill_in 'Andere Anforderungen', with: 'asdfasdf'
    fill_in 'Beruf oder Ausbildung im Herkunftsland', with: 'asdfasdf'
    fill_in 'Aktuelle Tätigkeiten', with: 'asdfasdf'
    fill_in 'Interessen', with: 'asdfasdf'
    select('Angemeldet', from: 'Prozess')
    fill_in 'Bemerkungen [intern]', with: 'asdfasdf'
    fill_in 'Anmeldende Stelle', with: 'asdfasdf'
    fill_in 'Weitere involvierte Stellen', with: 'asdfasdf'
    select @social_worker.dropdown_label, from: 'Fallführende Stelle'
    select('Gemeinde', from: 'Kostenträger')
    page.check('client_evening')
    fill_in 'Genauere Angaben', with: 'After 7'

    click_button 'Klient/in erfassen', match: :first
    assert_text 'Klient/in wurde erfolgreich erstellt.'
    assert page.has_select? 'Fallführende Stelle', selected: @social_worker.dropdown_label
  end

  test 'new client form with preselected fields' do
    login_as @superadmin
    visit new_client_path
    select('Frau', from: 'Anrede')
    fill_in 'Vorname', with: 'Client'
    fill_in 'Nachname', with: "doesn't matter"
    fill_in 'Telefonnummer', with: '0123456789', match: :first
    fill_in 'Strasse', with: 'Sihlstrasse 131'
    fill_in 'PLZ', with: '8002'
    fill_in 'Ort', with: 'Zürich'
    fill_in 'Mailadresse', with: FFaker::Internet.unique.email
    within '#languages' do
      choose('Gut')
    end
    click_button 'Klient/in erfassen', match: :first
    assert_text 'Klient/in wurde erfolgreich erstellt.'
    refute_select 'Beendet', wait: 0

    assert_select 'Geschlecht Freiwillige/r', selected: 'egal'
    assert_select 'Alter Freiwillige/r', selected: 'egal'
    assert_field 'Gut', checked: true
  end

  test 'new client can select custom language' do
    login_as @superadmin
    visit new_client_path
    select('Frau', from: 'Anrede')
    fill_in 'Vorname', with: 'Aymara'
    fill_in 'Nachname', with: 'Aymara'
    fill_in 'Mailadresse', with: 'client@aoz.com'
    fill_in 'Telefonnummer', with: '0123456789', match: :first
    fill_in 'Strasse', with: 'Sihlstrasse 131'
    fill_in 'PLZ', with: '8002'
    fill_in 'Ort', with: 'Zürich'

    within '#languages' do
      choose('Gut')
    end

    click_on('Sprache hinzufügen')
    select('Aymara', from: 'Sprache')
    select('Muttersprache', from: 'Niveau')

    click_button 'Klient/in erfassen', match: :first
    assert_text 'Klient/in wurde erfolgreich erstellt.'
    assert_select 'Sprache', selected: 'Aymara'
    assert_select 'Niveau', selected: 'Muttersprache'
    assert_field 'Gut', checked: true
  end

  test 'client_pagination' do
    login_as @superadmin
    70.times do
      create :client
    end
    visit clients_path
    first(:link, '2').click
    Client.order('acceptance asc').paginate(page: 2).each do |client|
      assert_text client.contact.full_name
    end

    within page.first('.pagination') do
      assert page.has_link? '1', href: clients_path(page: 1)
      assert page.has_link? 'Zurück', href: clients_path(page: 1)
    end
  end

  test 'superadmin_sees_all_required_features_in_index' do
    with_assignment, without_assignment = create_clients_for_index_text_check
    login_as @superadmin
    visit clients_path

    assert_link 'Anzeigen', count: 2
    assert_link 'Bearbeiten', count: 2
    assert_link 'Beenden', count: 2

    assert_text with_assignment.contact.full_name
    assert_text without_assignment.contact.full_name

    assert_text 'unassigned_goals unassigned_interests unassigned_authority ' +
      I18n.l(without_assignment.created_at.to_date)
    assert_text 'assigned_goals assigned_interests assigned_authority ' +
      I18n.l(with_assignment.created_at.to_date)
  end

  test 'client cannot be terminated if has active missions' do
    client = create :client
    create :assignment, client: client,
                        period_start: 3.weeks.ago,
                        period_end: 2.days.ago,
                        period_end_set_by: @superadmin
    assignment2 = create :assignment, client: client,
                                      period_start: 3.weeks.ago,
                                      period_end: nil
    refute client.resigned?

    login_as @superadmin
    visit client_path(client)
    find_all("a[href='#{set_terminated_client_path(client)}']").first.click
    page.driver.browser.switch_to.alert.accept
    assert_text 'Klient/in kann nicht beendet werden, solange noch ein laufendes Tandem existiert.'

    assignment2.update(period_end: 1.day.ago)

    find_all("a[href='#{set_terminated_client_path(client)}']").last.click

    page.driver.browser.switch_to.alert.accept
    assert_text 'Klient/in wurde erfolgreich beendet.'
    assert client.reload.resigned?
  end

  test 'all_needed_actions_are_available_in_the_index' do
    use_rack_driver
    client = create :client
    social_worker = create :social_worker
    client_department_manager = create :client, user: @department_manager
    client_social_worker = create :client, user: social_worker

    login_as @superadmin
    visit clients_path
    assert page.has_link? 'Anzeigen', count: 3
    assert page.has_link? 'Bearbeiten', count: 3

    login_as @department_manager
    visit clients_path
    assert_text client_department_manager
    refute_text client_social_worker, wait: 0
    refute_text client, wait: 0
    assert page.has_link? 'Anzeigen'
    assert page.has_link? 'Bearbeiten', href: edit_client_path(client_department_manager)
    refute page.has_link? 'Bearbeiten', href: edit_client_path(client_social_worker), wait: 0

    login_as social_worker
    visit clients_path
    assert_text client_social_worker
    refute_text client_department_manager, wait: 0
    refute_text client, wait: 0
    assert page.has_link? 'Anzeigen'
    refute page.has_link? 'Bearbeiten', href: edit_client_path(client_department_manager), wait: 0
    assert page.has_link? 'Bearbeiten', href: edit_client_path(client_social_worker)
  end

  test 'department_manager_sees_his_scoped_client_index_correctly' do
    superadmins_client = create :client, user: @superadmin
    with_assignment, without_assignment = create_clients_for_index_text_check
    with_assignment.update(user: @department_manager)
    without_assignment.update(user: @department_manager)
    login_as @department_manager
    visit clients_path

    assert_link 'Anzeigen', count: 2
    assert_link 'Bearbeiten', count: 2
    assert_link 'Beenden', count: 2

    assert_text with_assignment.contact.full_name
    assert_text without_assignment.contact.full_name

    assert_text 'unassigned_goals unassigned_interests unassigned_authority ' +
      I18n.l(without_assignment.created_at.to_date)
    assert_text 'assigned_goals assigned_interests assigned_authority ' +
      I18n.l(with_assignment.created_at.to_date)

    refute_text superadmins_client.contact.full_name, wait: 1
  end

  test 'client_index_shows_german_and_native_languages_only' do
    create :client, language_skills: [
      create(:language_skill, language: 'DE', level: 'good'),
      create(:language_skill, language: 'IT', level: 'native_speaker'),
      create(:language_skill, language: 'FR', level: 'good')
    ]
    login_as @superadmin
    visit clients_path
    assert_text 'Deutsch, Gut'
    assert_text 'Italienisch, Muttersprache'
    refute_text 'Französisch, Mittel', wait: 0
  end

  test 'new_client_form_has_german_with_its_non_native_speaker_abilities' do
    login_as @superadmin
    visit new_client_path
    assert_text 'Sprachkenntnisse Deutsch * Niveau', normalize_ws: true
    within '#languages' do
      choose('Wenig')
    end
    select('Frau', from: 'Anrede')
    fill_in 'Vorname', with: 'Client'
    fill_in 'Nachname', with: "doesn't matter"
    fill_in 'Mailadresse', with: 'client@aoz.com'
    fill_in 'Telefonnummer', with: '0123456789', match: :first
    fill_in 'Strasse', with: 'Sihlstrasse 131'
    fill_in 'PLZ', with: '8002'
    fill_in 'Ort', with: 'Zürich'
    click_button 'Klient/in erfassen', match: :first

    assert_field 'Wenig', checked: true
  end

  test 'client_print_view_is_not_paginated' do
    45.times { create :client }
    login_as @superadmin
    visit clients_url(print: true)
    assert_equal Client.count, find_all('tbody tr').size
  end

  def create_clients_for_index_text_check
    with_assignment = create :client, comments: 'with_assignment',
                                      competent_authority: 'assigned_authority',
                                      goals: 'assigned_goals', interests: 'assigned_interests'
    create :assignment, volunteer: create(:volunteer), client: with_assignment
    with_assignment.update(created_at: 2.days.ago)
    without_assignment = create :client, comments: 'without_assignment',
                                         competent_authority: 'unassigned_authority',
                                         goals: 'unassigned_goals',
                                         interests: 'unassigned_interests'
    without_assignment.update(created_at: 4.days.ago)
    [with_assignment, without_assignment]
  end

  test 'If social worker registers a client, she is automatically the involved authority' do
    login_as @social_worker
    visit new_client_path

    within '#languages' do
      choose('Wenig')
    end
    select('Frau', from: 'Anrede')
    fill_in 'Vorname', with: 'Client'
    fill_in 'Nachname', with: "doesn't matter"
    fill_in 'Mailadresse', with: 'client@aoz.com'
    fill_in 'Telefonnummer', with: '0123456789', match: :first
    fill_in 'Strasse', with: 'Sihlstrasse 131'
    fill_in 'PLZ', with: '8002'
    fill_in 'Ort', with: 'Zürich'
    refute page.has_select? 'Fallführende Stelle', wait: 0

    click_button 'Klient/in erfassen', match: :first

    login_as @superadmin
    visit client_path(Client.last)
    assert page.has_link? @social_worker.full_name, count: 2
  end

  test 'client table should display inactive status' do
    # clear out all existing clients
    Client.delete_all
    client = create :client, :with_relatives, :with_language_skills
    create :assignment_inactive, client: client

    login_as @superadmin
    visit clients_path
    assert_text 'Inaktiv'
  end

  test 'client table should display active status' do
    # clear out all existing clients
    Client.delete_all
    client = create :client, :with_relatives, :with_language_skills
    create :assignment_active, client: client

    login_as @superadmin
    visit clients_path
    assert_text 'Aktiv'
  end

  test 'superadmin, department_manager, social_worker can destroy inactive clients' do
    [@superadmin, @department_manager, @social_worker].each do |user|
      client = create :client, user: user
      client_css = "##{dom_id client}"
      login_as user

      visit clients_path
      assert page.has_css? client_css
      within client_css do
        assert page.has_link? 'Löschen'
        assert page.has_text? client
      end

      page.accept_confirm do
        click_link 'Löschen'
      end
      assert_text 'Klient/in wurde erfolgreich gelöscht.'
    end
  end

  test 'no user can destroy client with assignment associated' do
    [@superadmin, @department_manager, @social_worker].each do |user|
      client = create :client, user: user
      create :assignment, client: client
      client_css = "##{dom_id client}"
      login_as user

      visit clients_path
      within client_css do
        assert page.has_text? client
        refute page.has_link? 'Löschen', wait: 0
      end
    end
  end

  test 'no user can destroy client with deleted assignment associated' do
    [@superadmin, @department_manager, @social_worker].each do |user|
      client = create :client, user: user
      assignment = create :assignment, client: client
      client_css = "##{dom_id client}"

      assignment.destroy
      login_as user

      visit clients_path
      within client_css do
        assert page.has_text? client
        refute page.has_link? 'Löschen', wait: 0
      end
    end
  end
end
