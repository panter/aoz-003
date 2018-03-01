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
      select('1995', from: 'Jahrgang')
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
    select('Akan', from: 'Sprache')
    select('Mittel', from: 'Niveau')
    click_on('Verwandte hinzufügen')
    within '#relatives' do
      fill_in 'Vorname', with: 'asdf'
      fill_in 'Nachname', with: 'asdf'
      select('2001', from: 'Jahrgang')
      select('Onkel', from: 'Verwandtschaftsbeziehung')
    end
    fill_in 'Inhalte der Begleitung', with: 'asdfasdf'
    select("egal", from: "Geschlecht Freiwillige/r")
    select('36 - 50', from: "Alter Freiwillige/r")
    fill_in 'Andere Anforderungen', with: 'asdfasdf'
    fill_in 'Beruf oder Ausbildung im Herkunftsland', with: 'asdfasdf'
    fill_in 'Aktuelle Tätigkeiten', with: 'asdfasdf'
    fill_in 'Interessen', with: 'asdfasdf'
    select('Angemeldet', from: 'Affirmation')
    fill_in 'Bemerkungen', with: 'asdfasdf'
    fill_in 'Anmeldende Stelle', with: 'asdfasdf'
    select @social_worker.full_name, from: 'Fallführende Stelle'
    select('Gemeinde', from: 'Kostenträger')
    page.check('client_evening')
    fill_in 'Genauere Angaben', with: 'After 7'

    click_button 'Klient/in erfassen'
    assert page.has_text? 'Klient/in wurde erfolgreich erstellt.'
    assert page.has_text? @social_worker.full_name
    @superadmin.clients.each do |client|
      assert page.has_link? client.involved_authority.full_name, href: /profiles\/#{client.involved_authority.profile.id}/
      assert page.has_link? client.user.full_name, href: /profiles\/#{client.user.profile.id}/
      assert page.has_link? client.contact.primary_email
    end
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
    within '#languages' do
      choose('Gut')
    end
    click_button 'Klient/in erfassen'
    assert page.has_text? 'Klient/in wurde erfolgreich erstellt.'
    within '.table-no-border-top' do
      assert page.has_text? "egal", count: 2
      assert page.has_text? 'Deutsch Gut'
    end
  end

  test 'new client can select custom language' do
    login_as @superadmin
    visit new_client_path
    select('Frau', from: 'Anrede')
    fill_in 'Vorname', with: 'Dari'
    fill_in 'Nachname', with: 'Dari'
    fill_in 'Mailadresse', with: 'client@aoz.com'
    fill_in 'Telefonnummer', with: '0123456789', match: :first
    fill_in 'Strasse', with: 'Sihlstrasse 131'
    fill_in 'PLZ', with: '8002'
    fill_in 'Ort', with: 'Zürich'

    within '#languages' do
      choose('Gut')
    end

    click_on('Sprache hinzufügen')
    select('Dari', from: 'Sprache')
    select('Muttersprache', from: 'Niveau')

    click_button 'Klient/in erfassen'
    assert page.has_text? 'Klient/in wurde erfolgreich erstellt.'
    within '.table-no-border-top' do
      assert page.has_text? 'Dari Muttersprache'
      assert page.has_text? 'Deutsch Gut'
    end
  end

  test 'level without a language is not shown' do
    login_as @superadmin
    visit new_client_path
    select('Frau', from: 'Anrede')
    fill_in 'Vorname', with: 'asdf'
    fill_in 'Nachname', with: 'asdf'
    fill_in 'Strasse', with: 'Sihlstrasse 131'
    fill_in 'PLZ', with: '8002'
    fill_in 'Ort', with: 'Zürich'
    fill_in 'Mailadresse', with: 'gurke@gurkenmail.com'
    fill_in 'Telefonnummer', with: '0123456789', match: :first
    within '#languages' do
      choose('Wenig')
    end

    click_on('Sprache hinzufügen')
    select('Mittel', from: 'Niveau')

    click_button 'Klient/in erfassen'
    within '.table-no-border-top' do
      refute page.has_text? 'Mittel'
      assert page.has_text? 'Deutsch Wenig'
    end

    visit clients_path
    refute page.has_text? 'Mittel'
  end

  test 'clients_default_filters' do
    client = create :client, acceptance: :resigned
    client.contact.update(first_name: 'Resigned client')

    login_as @superadmin
    visit clients_path

    assert page.has_text? 'Affirmation: Nicht beendet'
    refute page.has_text? 'Resigned client'
  end

  test 'client_pagination' do
    login_as @superadmin
    70.times do
      create :client
    end
    visit clients_path
    first(:link, '2').click
    Client.order('created_at desc').paginate(page: 2).each do |client|
      assert page.has_text? client.contact.full_name
    end

    within page.first('.pagination') do
      assert page.has_link? '1',
        href: clients_path(page: 1, q: { acceptance_scope: :not_resigned })
      assert page.has_link? 'Zurück',
        href: clients_path(page: 1, q: { acceptance_scope: :not_resigned })
    end
  end

  test 'superadmin_sees_all_required_features_in_index' do
    with_assignment, without_assignment = create_clients_for_index_text_check
    login_as @superadmin
    visit clients_path
    assert page.has_text? with_assignment.contact.full_name
    assert page.has_text? without_assignment.contact.full_name
    assert page.has_text? 'unassigned_goals unassigned_interests  unassigned_authority '\
      "#{I18n.l(without_assignment.created_at.to_date)} Angemeldet without_assignment Anzeigen Bearbeiten"
    assert page.has_text? 'assigned_goals assigned_interests assigned_authority '\
      "#{I18n.l(with_assignment.created_at.to_date)} Angemeldet with_assignment Anzeigen Bearbeiten"
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
    assert page.has_text? client_department_manager
    refute page.has_text? client_social_worker
    refute page.has_text? client
    assert page.has_link? 'Anzeigen'
    assert page.has_link? 'Bearbeiten', href: edit_client_path(client_department_manager)
    refute page.has_link? 'Bearbeiten', href: edit_client_path(client_social_worker)

    login_as social_worker
    visit clients_path
    assert page.has_text? client_social_worker
    refute page.has_text? client_department_manager
    refute page.has_text? client
    assert page.has_link? 'Anzeigen'
    refute page.has_link? 'Bearbeiten', href: edit_client_path(client_department_manager)
    assert page.has_link? 'Bearbeiten', href: edit_client_path(client_social_worker)
  end

  test 'department_manager_sees_his_scoped_client_index_correctly' do
    superadmins_client = create :client, user: @superadmin
    with_assignment, without_assignment = create_clients_for_index_text_check
    with_assignment.update(user: @department_manager)
    without_assignment.update(user: @department_manager)
    login_as @department_manager
    visit clients_path
    assert page.has_text? with_assignment.contact.full_name
    assert page.has_text? without_assignment.contact.full_name
    assert page.has_text? 'unassigned_goals unassigned_interests unassigned_authority '\
      "#{I18n.l(without_assignment.created_at.to_date)} Anzeigen"
    assert page.has_text? 'assigned_goals assigned_interests assigned_authority '\
      "#{I18n.l(with_assignment.created_at.to_date)} Anzeigen"
    refute page.has_text? superadmins_client.contact.full_name
  end

  test 'client_index_shows_german_and_native_languages_only' do
    create :client, language_skills: [
      create(:language_skill, language: 'DE', level: 'good'),
      create(:language_skill, language: 'IT', level: 'native_speaker'),
      create(:language_skill, language: 'FR', level: 'fluent')
    ]
    login_as @superadmin
    visit clients_path
    assert page.has_text? 'Deutsch, Gut'
    assert page.has_text? 'Italienisch, Muttersprache'
    refute page.has_text? 'Französisch, Mittel'
  end

  test 'new_client_form_has_german_with_its_non_native_speaker_abilities' do
    login_as @superadmin
    visit new_client_path
    assert page.has_text? 'Sprachkenntnisse Deutsch * Niveau'
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
    click_button 'Klient/in erfassen'
    assert page.has_text? 'Deutsch Wenig'
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
                                goals: 'unassigned_goals', interests: 'unassigned_interests'
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
    refute page.has_select? 'Fallführende Stelle'

    click_button 'Klient/in erfassen'

    login_as @superadmin
    visit client_path(Client.last)
    assert page.has_link? @social_worker.full_name, count: 2
  end
end
