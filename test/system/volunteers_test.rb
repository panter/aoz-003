require 'application_system_test_case'

class VolunteersTest < ApplicationSystemTestCase
  setup do
    @user = create :user, email: 'superadmin@example.com'
    login_as @user
    Volunteer.acceptance_collection.each do |acceptance|
      create :volunteer, acceptance: acceptance, waive: false
    end
    ActionMailer::Base.deliveries.clear
  end

  test 'new volunteer form' do
    create(:group_offer_category, category_name: 'Training')
    create(:group_offer_category, category_name: 'German Course')
    create(:group_offer_category, category_name: 'Other Offer')
    create(:group_offer_category, category_name: 'Kurzbegleitungen bei Wohnungsbezug in Zürich-Stadt')

    visit new_volunteer_path

    select('Frau', from: 'Anrede')
    fill_in 'Vorname', with: 'Volunteer'
    fill_in 'Nachname', with: 'aoz'
    #within '.volunteer_birth_year' do
    #  select('1988', from: 'Jahrgang')
    #end
    page.execute_script("$('#volunteer_birth_year').val('01/01/1988')")
    select('Syrien, Arabische Republik', from: 'Nationalität')
    fill_in 'Strasse', with: 'Sihlstrasse 131'
    fill_in 'PLZ', with: '8002'
    fill_in 'Ort', with: 'Zürich'
    fill_in 'Mailadresse', with: 'gurke@gurkenmail.com'
    fill_in 'Telefonnummer', with: '0123456789'
    fill_in 'Beruf', with: 'Developer'
    fill_in 'Ausbildung', with: 'CEID'
    fill_in 'Was ist Ihre Motivation, Freiwilligenarbeit mit Migrant/innen zu leisten?', with: 'asfd'
    page.check('volunteer_experience')
    fill_in 'Was erwarten Sie von einer Person, die Sie begleiten würden / Ihrem Freiwilligeneinsatz?', with: 'asdf'
    fill_in 'Welche Stärken oder Kompetenzen (sozial, beruflich) könnten Sie in Ihre Freiwilligenarbeit einbringen?', with: 'asdf'
    fill_in 'Welche sind Ihre wichtigsten Freizeitinteressen?', with: 'asdf'
    page.check('Training')
    page.check('German Course')
    page.check('Other Offer')
    fill_in 'Beschreibung', with: 'Description'
    page.check('Kurzbegleitungen bei Wohnungsbezug in Zürich-Stadt')
    fill_in 'Bank', with: 'BankName'
    fill_in 'IBAN', with: 'CH01 2345 6789 0123 4567 8'
    page.check('volunteer_waive')
    page.check('volunteer_weekend')
    fill_in 'Genauere Angaben', with: 'I am every two weeks available on tuesdays asdfasdf.'

    first(:button, 'Freiwillige/n erfassen').click
    assert page.has_text? 'Freiwillige/r wurde erfolgreich erstellt.'
  end

  test 'show volunteer custom nationality (nationality_name test)' do
    visit new_volunteer_path
    select('Frau', from: 'Anrede')
    fill_in 'Vorname', with: 'Volunteer'
    fill_in 'Nachname', with: 'Volunteer'
    select('Kosovo', from: 'Nationalität')
    fill_in 'Mailadresse', with: 'volunteer@kosovo.com'
    fill_in 'Telefonnummer', with: '0123456789'
    select('Frau', from: 'Anrede')
    fill_in 'Strasse', with: 'Sihlstrasse 131'
    fill_in 'PLZ', with: '8002'
    fill_in 'Ort', with: 'Zürich'

    first(:button, 'Freiwillige/n erfassen').click

    assert page.has_text? 'Kosovo'
  end

  test 'show volunteer checklist' do
    visit new_volunteer_path
    select('Frau', from: 'Anrede')
    fill_in 'Vorname', with: 'Volunteer'
    fill_in 'Nachname', with: 'Volunteer'
    fill_in 'Mailadresse', with: 'volunteer@kosovo.com'
    fill_in 'Telefonnummer', with: '0123456789'
    fill_in 'Strasse', with: 'Sihlstrasse 131'
    fill_in 'PLZ', with: '8002'
    fill_in 'Ort', with: 'Zürich'

    page.check('volunteer_trial_period')
    page.check('volunteer_intro_course')
    page.check('volunteer_doc_sent')
    page.check('volunteer_bank_account')
    page.check('volunteer_evaluation')

    first(:button, 'Freiwillige/n erfassen').click

    assert page.has_field? 'Probezeitbericht erhalten', checked: true
    assert page.has_field? 'Einführungskurs besucht', checked: true
    assert page.has_field? 'Dossier Freiwillige engagiert verschickt', checked: true
    assert page.has_field? 'Kontodaten eingetragen', checked: true
    assert page.has_field? 'Abschlussevaluation erhalten', checked: true
  end

  test 'volunteer checklist has default values (false)' do
    visit new_volunteer_path
    select('Frau', from: 'Anrede')
    fill_in 'Vorname', with: 'Volunteer'
    fill_in 'Nachname', with: 'Volunteer'
    fill_in 'Mailadresse', with: 'volunteer@kosovo.com'
    fill_in 'Telefonnummer', with: '0123456789'
    fill_in 'Strasse', with: 'Sihlstrasse 131'
    fill_in 'PLZ', with: '8002'
    fill_in 'Ort', with: 'Zürich'

    first(:button, 'Freiwillige/n erfassen').click

    assert page.has_field? 'Probezeitbericht erhalten', checked: false
    assert page.has_field? 'Einführungskurs besucht', checked: false
    assert page.has_field? 'Dossier Freiwillige engagiert verschickt', checked: false
    assert page.has_field? 'Kontodaten eingetragen', checked: false
    assert page.has_field? 'Abschlussevaluation erhalten', checked: false
  end

  test 'rejection fields are shown only when the volunteer is rejected' do
    visit new_volunteer_path
    refute page.has_text? 'Grund für die Ablehnung'
    refute page.has_field? 'Erläuterung zur Ablehnung'

    volunteer = create :volunteer

    visit volunteer_path(volunteer)
    refute page.has_text? 'Grund für die Ablehnung'
    refute page.has_text? 'Erläuterung zur Ablehnung'

    visit edit_volunteer_path(volunteer)
    refute page.has_text? 'Grund für die Ablehnung'
    refute page.has_field? 'Erläuterung zur Ablehnung'
    find("option[value='rejected']").click
    assert page.has_content? 'Grund für die Ablehnung'
    page.choose('volunteer_rejection_type_other')
    assert page.has_field? 'Erläuterung zur Ablehnung'
    fill_in 'Erläuterung zur Ablehnung', with: 'Explanation'
    first(:button, 'Freiwillige/n aktualisieren').click

    visit volunteer_path(volunteer)
    assert page.has_content? 'Grund für die Ablehnung: Anderer Grund'
    assert page.has_content? 'Erläuterung zur Ablehnung: Explanation'
  end

  test 'volunteer form has working_percent field' do
    visit edit_volunteer_path(Volunteer.first)
    assert page.has_field? 'Stellenprozent'
  end

  test 'volunteer has no secondary phone field' do
    visit new_volunteer_path
    refute page.has_text? 'Telefonnummer 2'

    visit volunteer_path(Volunteer.first)
    refute page.has_text? 'Telefonnummer 2'
  end

  test 'volunteer_experience_description_field_is_conditional' do
    visit new_volunteer_path
    refute page.has_text? 'Falls Sie bereits Erfahrungen mit Freiwilligenarbeit haben, bitte diese genauer erläutern.'
    page.check('volunteer_experience')
    assert page.has_text? 'Falls Sie bereits Erfahrungen mit Freiwilligenarbeit haben, bitte diese genauer erläutern.'
    page.uncheck('volunteer_experience')
    refute page.has_text? 'Falls Sie bereits Erfahrungen mit Freiwilligenarbeit haben, bitte diese genauer erläutern.'
  end

  test 'volunteer_pagination' do
    really_destroy_with_deleted(Volunteer)
    (1..20).to_a.map do
      volunteer = create :volunteer
      volunteer.update created_at: 10.days.ago
      volunteer.contact.update(
        first_name: 'second_page',
        last_name: 'second_page' + volunteer.contact.last_name
      )
      volunteer
    end
    20.times do
      create :volunteer
    end
    visit volunteers_path
    first(:link, '2').click
    visit current_url

    assert page.has_css? '.pagination'
    Volunteer.order('acceptance asc').paginate(page: 2).each do |volunteer|
      assert page.has_text? "#{volunteer.contact.full_name} #{volunteer.contact.city}"\
        " #{volunteer.contact.postal_code}"
    end

    within page.first('.pagination') do
      assert page.has_link? '1', href: volunteers_path(page: 1)
      assert page.has_link? 'Zurück', href: volunteers_path(page: 1)
    end
  end

  test 'volunteer (with assignments) index partial has no journal link' do
    volunteer = create :volunteer
    create :assignment, volunteer: volunteer
    visit volunteer_path(volunteer)
    within '.assignments-table' do
      refute page.has_link? 'Journal'
    end
  end

  test 'social_worker_cannot_see_volunteer_index' do
    login_as create(:social_worker)

    visit volunteers_path

    assert page.has_text? 'Sie sind nicht berechtigt diese Aktion durchzuführen.'
  end

  test 'social_worker_cant_see_volunteer_seeking_clients' do
    social_worker = create :social_worker
    login_as social_worker

    visit seeking_clients_volunteers_path

    assert page.has_text? 'Sie sind nicht berechtigt diese Aktion durchzuführen.'
  end

  test 'accepted at creation volunteer gets invited' do
    visit new_volunteer_path
    find("option[value='accepted']").click
    select('Frau', from: 'Anrede')
    fill_in 'Vorname', with: 'Volunteer'
    fill_in 'Nachname', with: 'accepted'
    fill_in 'Strasse', with: 'Sihlstrasse 131'
    fill_in 'PLZ', with: '8002'
    fill_in 'Ort', with: 'Zürich'
    fill_in 'Mailadresse', with: 'volunteer@aoz.ch'
    fill_in 'Telefonnummer', with: '0123456789'
    first(:button, 'Freiwillige/n erfassen').click

    assert page.has_text? 'Freiwillige/r wurde erfolgreich erstellt. Einladung wurde an volunteer@aoz.ch verschickt.'
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test 'undecided to accepted volunteer gets invited' do
    volunteer = create :volunteer, acceptance: 'undecided'
    visit edit_volunteer_path(volunteer)
    find("option[value='accepted']").click
    first(:button, 'Freiwillige/n aktualisieren').click

    assert page.has_text? "Einladung wurde an #{volunteer.contact.primary_email} verschickt."
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test 'imported_create_account_for_imported_volunteer' do
    use_rack_driver
    really_destroy_with_deleted(Volunteer)
    volunteer = create :volunteer
    volunteer.user.really_destroy!
    import = Import.create(base_origin_entity: 'tbl_Personenrollen', access_id: 1,
      importable: volunteer, store: { haupt_person: { email: 'imported@example.com' } })
    visit volunteers_path
    assert page.has_text? 'Kein Login'
    assert page.has_text? 'Importiert'
    click_link 'Anzeigen', href: volunteer_path(volunteer)
    assert page.has_text? "Für die Emailadresse #{import.email} einen Account erstellen"
    assert page.has_field? 'Mailadresse', with: import.email
    click_button 'Einladung an angegebene E-Mail verschicken'
    assert page.has_text? 'Freiwillige/r erhält eine Accountaktivierungs-Email.'
  end

  test 'imported_create_account_with_invalid_imported_email' do
    use_rack_driver
    volunteer = create :volunteer
    volunteer.user.really_destroy!
    Import.create(base_origin_entity: 'tbl_Personenrollen', access_id: 1,
      importable: volunteer, store: { haupt_person: { email: 'invalid' } })
    visit volunteer_path(volunteer)
    assert page.has_text? 'Scheinbar ist die importierte Mailadresse nicht gültig.'
    assert_empty find_field('Mailadresse').value
    fill_in 'Mailadresse', with: 'some_email@example.com'
    click_button 'Einladung an angegebene E-Mail verschicken'
    assert page.has_text? 'Freiwillige/r erhält eine Accountaktivierungs-Email.'
  end

  test 'imported_create_account_no_email_imported_enter_inavalid_email' do
    use_rack_driver
    volunteer = create :volunteer
    volunteer.user.really_destroy!
    Import.create(base_origin_entity: 'tbl_Personenrollen', access_id: 1, importable: volunteer,
      store: { haupt_person: { email: nil } })
    visit volunteer_path(volunteer)
    assert page.has_text? 'Es wird eine gültige Emailadresse des Freiwilligen benötigt, um einen'
    assert_empty find_field('Mailadresse').value
    fill_in 'Mailadresse', with: 'invalid'
    click_button 'Einladung an angegebene E-Mail verschicken'
    within '.alert.alert-danger.alert-dismissible' do
      assert page.has_text? 'Die Mailadresse ist scheinbar nicht gültig'
      assert page.has_link? 'Mailadresse konfigurieren', href: edit_volunteer_path(volunteer)
    end
  end

  test 'imported volunteer can be invited more than once' do
    use_rack_driver
    really_destroy_with_deleted(Volunteer)
    volunteer = create :volunteer
    volunteer.user.really_destroy!
    import = Import.create(base_origin_entity: 'tbl_Personenrollen', access_id: 1,
      importable: volunteer, store: { haupt_person: { email: 'imported@example.com' } })
    ActionMailer::Base.deliveries.clear

    visit volunteers_path
    assert page.has_text? 'Kein Login'
    assert page.has_text? 'Importiert'

    click_link 'Anzeigen', href: volunteer_path(volunteer)
    assert page.has_text? 'User Account erstellen'
    assert page.has_text? "Für die Emailadresse #{import.email} einen Account erstellen"
    assert page.has_field? 'Mailadresse', with: import.email
    refute page.has_css? '#reinvite_field', visible: false

    # invite volunteer for the first time
    click_button 'Einladung an angegebene E-Mail verschicken'
    assert page.has_text? 'User Account erstellen'
    assert page.has_text? 'Freiwillige/r erhält eine Accountaktivierungs-Email.'
    assert page.has_text? "Für die Emailadresse #{import.email} einen Account erstellen"
    assert page.has_field? 'Mailadresse', with: import.email
    assert page.has_css? '#reinvite_field', visible: false
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal import.email, ActionMailer::Base.deliveries.first.to.first
    assert_equal volunteer.reload.user.email, import.email
    assert_equal volunteer.contact.primary_email, import.email

    # invite volunteer second time
    ActionMailer::Base.deliveries.clear
    new_address = 'new_address@example.com'
    fill_in 'Mailadresse', with: new_address
    click_button 'Einladung an angegebene E-Mail verschicken'
    assert page.has_text? 'User Account erstellen'
    assert page.has_text? 'Freiwillige/r erhält eine Accountaktivierungs-Email.'
    assert page.has_text? "Für die Emailadresse #{new_address} einen Account erstellen"
    assert page.has_field? 'Mailadresse', with: new_address
    assert page.has_css? '#reinvite_field', visible: false
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal new_address, ActionMailer::Base.deliveries.first.to.first
    assert_equal volunteer.reload.user.email, new_address
    assert_equal volunteer.contact.primary_email, new_address

    # invite volunteer third time
    ActionMailer::Base.deliveries.clear
    new_address = 'new_address2@example.com'
    fill_in 'Mailadresse', with: new_address
    click_button 'Einladung an angegebene E-Mail verschicken'
    assert page.has_text? 'User Account erstellen'
    assert page.has_text? 'Freiwillige/r erhält eine Accountaktivierungs-Email.'
    assert page.has_text? "Für die Emailadresse #{new_address} einen Account erstellen"
    assert page.has_field? 'Mailadresse', with: new_address
    assert page.has_css? '#reinvite_field', visible: false
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal new_address, ActionMailer::Base.deliveries.first.to.first
    assert_equal volunteer.reload.user.email, new_address
    assert_equal volunteer.contact.primary_email, new_address

    # manually accept volunteer's user
    volunteer.reload.user.update(invitation_accepted_at: Time.now)
    visit edit_volunteer_path(volunteer)
    refute page.has_text? 'User Account erstellen'
    refute page.has_text? "Für die Emailadresse #{new_address} einen Account erstellen"
    refute page.has_css? '#reinvite_field', visible: false
  end

  test 'not resigned volunteer can not be terminated via acceptance select in edit' do
    @undecided = create :volunteer, acceptance: :undecided
    @invited = create :volunteer, acceptance: :invited
    @accepted = create :volunteer, acceptance: :accepted
    @rejected = create :volunteer, acceptance: :rejected

    visit edit_volunteer_path(@undecided)
    refute page.has_select? 'Beendet'

    visit edit_volunteer_path(@invited)
    refute page.has_select? 'Beendet'

    visit edit_volunteer_path(@accepted)
    refute page.has_select? 'Beendet'

    visit edit_volunteer_path(@rejected)
    refute page.has_select? 'Beendet'
  end

  test 'resigned volunteers acceptance can not be changed in edit anymore' do
    @resigned = create :volunteer, acceptance: :resigned

    visit edit_volunteer_path(@resigned)
    assert page.has_field? 'Prozess', disabled: true
  end

  test 'external volunteer can not get machted with a client' do
    @external = create :volunteer, external: true
    visit volunteers_path

    # "Klient/en" suchen button is not shown on volunteer index
    within page.find('tr', text: @external.full_name) do
      assert_text 'Nicht zuweisbar'
    end

    # "Klient/en" suchen button is not shown on volunteer show
    visit volunteer_path(@external)
    refute page.has_button? 'Klient/in suchen'

    # "Klient/en" suchen button is not shown on volunteer edit
    visit edit_volunteer_path(@external)
    refute page.has_button? 'Klient/in suchen'
  end

  test 'department_manager_can_see_acceptance_manipulation_on_his_volunteers_edit' do
    department_manager = create :department_manager
    volunteer = create :volunteer_with_user, registrar: department_manager, acceptance: :undecided
    login_as department_manager
    visit edit_volunteer_path(volunteer)
    assert page.has_text? 'Aufnahme Verwaltung'
    assert page.has_select?('Prozess')
  end

  test 'superadmin can change department of volunteer' do
    volunteer = Volunteer.last
    department = create :department

    visit edit_volunteer_path volunteer

    select department.contact.last_name, from: 'Standort'
    click_button 'Freiwillige/n aktualisieren', match: :first

    assert page.has_text? 'Freiwillige/r wurde erfolgreich aktualisiert.'
    assert_equal volunteer.reload.department, department
  end

  test 'department_manager can edit volunteer assigned to her department' do
    volunteer = Volunteer.last
    department = create :department
    department_manager = create :department_manager, department: [department]

    volunteer.update department: department

    login_as department_manager
    visit edit_volunteer_path volunteer

    select department.contact.last_name, from: 'Standort'
    click_button 'Freiwillige/n aktualisieren', match: :first

    assert page.has_text? 'Freiwillige/r wurde erfolgreich aktualisiert.'
    assert_equal volunteer.reload.department, department
  end
  test 'department_manager can edit volunteer assigned to her department with secondary department' do
    volunteer = Volunteer.last
    department = create :department
    department_manager = create :department_manager, department: [department]

    volunteer.update secondary_department: department

    login_as department_manager
    visit edit_volunteer_path volunteer

    select department.contact.last_name, from: 'Zweiter Standort'
    click_button 'Freiwillige/n aktualisieren', match: :first

    assert page.has_text? 'Freiwillige/r wurde erfolgreich aktualisiert.'
    assert_equal volunteer.reload.secondary_department, department
  end

  test 'department_manager can not edit volunteer assigned to another department' do
    volunteer = Volunteer.last
    department = create :department
    department_manager = create :department_manager, department: [department]

    login_as department_manager
    visit edit_volunteer_path volunteer

    assert page.has_text? I18n.t('not_authorized')
  end

  test 'department_manager can take over volunteer with acceptance undecided' do
    department_manager = create :department_manager
    other_department_manager = create :department_manager
    department = department_manager.department.last
    other_department = other_department_manager.department.last

    volunteer = Volunteer.undecided.last
    volunteer_selector = "tr##{dom_id(volunteer)}"

    volunteer.update department: nil

    Volunteer.where.not(acceptance: :undecided).each do |volunteer|
      volunteer.update department: department
    end

    login_as other_department_manager
    visit volunteers_path

    assert page.has_selector? volunteer_selector

    within volunteer_selector do
      click_link 'Bearbeiten'
    end

    assert page.has_text? "#{volunteer}"
    assert page.has_text? 'Standort'
    assert page.has_text? 'Prozess'

    select other_department.contact.last_name, from: 'Standort'
    click_button 'Freiwillige/n aktualisieren', match: :first

    assert page.has_text? 'Freiwillige/r wurde erfolgreich aktualisiert.'
    assert page.has_button? 'Freiwillige/n aktualisieren'
    assert_equal volunteer.reload.department, other_department

    visit volunteers_path

    assert page.has_selector? volunteer_selector

    within volunteer_selector do
      assert page.has_link? 'Bearbeiten'
    end

    login_as department_manager

    visit edit_volunteer_path(volunteer)
    assert page.has_text? I18n.t('not_authorized')

    visit volunteers_path

    refute page.has_selector? volunteer_selector

    visit edit_volunteer_path volunteer
    assert page.has_text? I18n.t('not_authorized')
  end

  test 'department is automatically set for department_manager when creating volunteer' do
    department_manager = create :department_manager
    department = department_manager.department.last
    Volunteer.destroy_all

    login_as department_manager
    visit new_volunteer_path

    select('Frau', from: 'Anrede')
    fill_in 'Vorname', with: 'Volunteer'
    fill_in 'Nachname', with: 'aoz'
    #within '.volunteer_birth_year' do
    #  select('1988', from: 'Jahrgang')
    #end
    page.execute_script("$('#volunteer_birth_year').val('01/01/1988')")
    fill_in 'Strasse', with: 'Sihlstrasse 131'
    fill_in 'PLZ', with: '8002'
    fill_in 'Ort', with: 'Zürich'
    fill_in 'Mailadresse', with: 'gurke@gurkenmail.com'
    fill_in 'Telefonnummer', with: '0123456789'
    click_button 'Freiwillige/n erfassen', match: :first

    assert page.has_text? I18n.t('volunteer_created')
    assert_equal Volunteer.last.department, department
  end

  test 'automatocally assigned department can be overwritten by department_manager' do
    department_manager = create :department_manager
    department = department_manager.department.last
    other_department = create :department
    Volunteer.destroy_all

    login_as department_manager
    visit new_volunteer_path

    select(other_department.contact.last_name, from: 'Standort')
    select('Frau', from: 'Anrede')
    fill_in 'Vorname', with: 'Volunteer'
    fill_in 'Nachname', with: 'aoz'
    #within '.volunteer_birth_year' do
    #  select('1988', from: 'Jahrgang')
    #end
    page.execute_script("$('#volunteer_birth_year').val('01/01/1988')")
    fill_in 'Strasse', with: 'Sihlstrasse 131'
    fill_in 'PLZ', with: '8002'
    fill_in 'Ort', with: 'Zürich'
    fill_in 'Mailadresse', with: 'gurke@gurkenmail.com'
    fill_in 'Telefonnummer', with: '0123456789'
    click_button 'Freiwillige/n erfassen', match: :first

    assert page.has_text? I18n.t('not_authorized')
    assert_equal Volunteer.last.department, other_department
  end

  test 'invite_imported_volunteer_as_user' do
    really_destroy_with_deleted(Assignment, GroupAssignment, Volunteer)
    volunteer = create(:volunteer, :imported)
    volunteer.update_column(:acceptance, :accepted)
    login_as @user
    visit volunteer_path(volunteer)
    assert page.has_text? 'User Account erstellen'
    assert page.has_field? 'Mailadresse', with: volunteer.import.email
    click_button 'Einladung an angegebene E-Mail verschicken'
    assert page.has_text? 'Freiwillige/r erhält eine Accountaktivierungs-Email.'
    volunteer.reload
    assert volunteer.user.invited_to_sign_up?
  end
end
