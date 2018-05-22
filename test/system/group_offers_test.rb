require 'application_system_test_case'

class GroupOffersTest < ApplicationSystemTestCase
  def setup
    @department_manager = create :department_manager
    @group_offer_category = create :group_offer_category
  end

  test 'new_group_offer_form' do
    login_as create(:user)
    visit new_group_offer_path

    fill_in 'Bezeichnung', with: 'asdf'
    choose 'Voll'
    select @group_offer_category.category_name, from: 'Kategorie'
    select @department_manager.department.first, from: 'Standort'
    select @department_manager, from: 'Verantwortliche/r'
    select '2', from: 'Anzahl der benötigten Freiwilligen'
    fill_in 'Beschreibung des Angebotes', with: 'asdf'
    page.check('group_offer_all')
    page.check('group_offer_regular')
    page.check('group_offer_weekend')
    fill_in 'Präzise Angaben (Tag und Uhrzeit) und genauen Zeitraum', with: 'asdf'

    click_button 'Gruppenangebot erfassen'
    assert page.has_text? 'Gruppenangebot wurde erfolgreich erstellt.'
  end

  test "department manager's offer belongs to their department" do
    department_manager = create :department_manager
    login_as department_manager
    visit new_group_offer_path

    fill_in 'Bezeichnung', with: 'asdf'
    select @group_offer_category.category_name, from: 'Kategorie'
    click_button 'Gruppenangebot erfassen'

    assert page.has_text? 'Gruppenangebot wurde erfolgreich erstellt.'
    refute page.has_select? 'Standort'
  end

  test 'category_for_a_group_offer_is_required' do
    login_as create(:user)
    visit new_group_offer_path

    click_button 'Gruppenangebot erfassen'
    assert page.has_text? 'Es sind Fehler aufgetreten. Bitte überprüfen Sie die rot markierten Felder.'
    assert page.has_text? 'muss ausgefüllt werden'
  end

  test 'group offer can be deactivated' do
    @group_offer = create :group_offer
    login_as create(:user)
    visit group_offer_path(@group_offer)
    assert page.has_text? @group_offer.title
    refute page.has_link? 'Aktivieren'
    accept_confirm do
      first(:link, 'Deaktivieren').click
    end

    assert page.has_text? @group_offer.title
    assert page.has_link? 'Aktivieren'
    refute page.has_link? 'Deaktivieren'
  end

  test 'group_offer_can_be_activated' do
    @group_offer = create :group_offer, active: false
    login_as create(:user)
    visit group_offer_path(@group_offer)
    assert page.has_text? @group_offer.title
    assert page.has_link? 'Aktivieren'
    accept_confirm do
      first(:link, 'Aktivieren').click
    end

    assert page.has_text? @group_offer.title
    assert page.has_link? 'Deaktivieren'
    refute page.has_link? 'Aktivieren'
  end

  test 'modifying volunteer dates does not create a log entry' do
    login_as create(:user)
    volunteer = create :volunteer
    group_offer = create :group_offer, volunteers: [volunteer]

    visit volunteer_path(volunteer)
    assert page.has_text? 'Aktuelle Gruppenangebote'
    assert page.has_link? group_offer.title
    refute page.has_text? 'Archivierte Gruppenangebote'
  end

  test 'deleting_volunteer_does_not_crash_group_offer_show' do
    login_as create(:user)
    volunteer1 = create :volunteer
    volunteer2 = create :volunteer
    group_offer = create :group_offer
    [volunteer1, volunteer2].map do |volunteer|
      create(:group_assignment, volunteer: volunteer, group_offer: group_offer)
    end
    visit group_offer_path(group_offer)
    assert page.has_link? volunteer1
    assert page.has_link? volunteer2

    Volunteer.find(volunteer1.id).destroy

    visit group_offer_path(group_offer)
    assert page.has_link? volunteer2
    refute page.has_link? volunteer1
  end

  test 'department_manager_can_only_add_volunteers_they_registered' do
    department_manager = create :department_manager
    volunteer_one = create :volunteer, registrar: department_manager
    volunteer_two = create :volunteer
    group_offer = create :group_offer, department: department_manager.department.first

    login_as department_manager
    visit group_offer_path(group_offer)
    click_link 'Freiwillige hinzufügen'

    within '#add-volunteers' do
      assert_text volunteer_one
      refute_text volunteer_two
    end
  end

  test 'department_manager cannot access group offer pages unless there is a department assigned' do
    department_manager = create :user, role: 'department_manager'
    login_as department_manager
    refute page.has_link? 'Gruppenangebote'
    visit group_offers_path
    assert page.has_text? 'Sie sind nicht berechtigt diese Aktion durchzuführen.'
    visit new_group_offer_path
    assert page.has_text? 'Sie sind nicht berechtigt diese Aktion durchzuführen.'
  end

  test 'add_volunteers_on_show' do
    group_offer = create :group_offer
    internal_volunteer = create :volunteer
    external_volunteer = create :volunteer, external: true

    login_as create(:user)
    visit group_offer_path(group_offer)
    click_link 'Freiwillige hinzufügen'

    within '#add-volunteers' do
      assert_text internal_volunteer
      refute_text external_volunteer
    end

    group_offer.update!(
      offer_type: :external_offer,
      organization: 'Acme Corporation',
      location: 'Texas'
    )
    visit group_offer_path(group_offer)
    click_link 'Freiwillige hinzufügen'

    within '#add-volunteers' do
      refute_text internal_volunteer
      assert_text external_volunteer
    end

    click_link 'Freiwillige/n hinzufügen'

    assert_text 'Freiwillige/r erfolgreich hinzugefügt.'

    click_link 'Freiwillige hinzufügen'

    within '.assignments-table' do
      assert_text external_volunteer
    end

    within '#add-volunteers' do
      refute_text external_volunteer
    end
  end

  test 'volunteer_selection_stays_visible_after_sorting' do
    group_offer = create :group_offer
    volunteer = create :volunteer

    login_as create(:user)
    visit group_offer_path(group_offer)
    click_link 'Freiwillige hinzufügen'

    within '#add-volunteers' do
      assert_text volunteer

      click_link 'Anrede'
    end

    within '#add-volunteers' do
      assert_text volunteer
    end
  end

  test 'basic_group_offer_find_volunteer_search_is_working' do
    group_offer = create :group_offer
    volunteer = create :volunteer
    volunteer_two = create :volunteer
    group_assignment = create :group_assignment, group_offer: group_offer, period_start: 2.days.ago

    login_as create(:user)
    visit group_offer_path(group_offer)
    click_link 'Freiwillige hinzufügen'

    within '#add-volunteers' do
      assert page.has_text? volunteer.contact.full_name
      assert page.has_text? volunteer_two.contact.full_name
      refute page.has_text? group_assignment.volunteer.contact.full_name

      fill_in id: 'q_contact_full_name_cont',	with: volunteer_two.contact.full_name
      click_button 'Suchen'
    end

    within '#add-volunteers' do
      assert page.has_text? volunteer_two.contact.full_name
      refute page.has_text? volunteer.contact.full_name
    end
  end

  test 'terminated_volunteer_is_not_listed_in_ad' do
    group_offer = create :group_offer
    volunteer = create :volunteer
    terminated = create :volunteer, acceptance: :resigned, resigned_at: 2.days.ago
    login_as create(:user)
    visit group_offer_path(group_offer)
    click_link 'Freiwillige hinzufügen'

    within '#add-volunteers' do
      assert page.has_text? volunteer.contact.full_name
      refute page.has_text? terminated.contact.full_name
    end
  end

  test 'offer_type_is_readonly_if_group_assignments_are_present' do
    group_offer = create :group_offer
    create :group_assignment, group_offer: group_offer

    login_as create(:user)
    visit edit_group_offer_path(group_offer)

    assert_checked_field 'group_offer[offer_type]', disabled: true
  end

  test 'offer_type_toggles_location_fields' do
    login_as create(:user)
    visit new_group_offer_path

    assert_field 'Internes Gruppenangebot', checked: true
    assert_field 'Standort'
    refute_field 'Organisation'
    refute_field 'Ort'

    choose 'Externes Gruppenangebot'

    refute_field 'Standort'
    assert_field 'Organisation'
    assert_field 'Ort'
  end

  test 'department manager can create external group offer' do
    login_as @department_manager
    visit new_group_offer_path

    assert_field 'Internes Gruppenangebot', checked: true
    refute_field 'Standort'
    refute_field 'Organisation'
    refute_field 'Ort'

    choose 'Externes Gruppenangebot'

    refute_field 'Standort'
    assert_field 'Organisation'
    assert_field 'Ort'
  end

  test 'creates/updates group assignment PDF when requested' do
    use_rack_driver

    pdf_date = 1.week.ago
    travel_to pdf_date

    group_offer = create :group_offer
    group_assignment = create :group_assignment, group_offer: group_offer
    login_as create(:user)
    visit group_offer_path(group_offer)

    within('.assignments-table') { refute_link 'Herunterladen' }

    # create initial PDF

    within('.assignments-table') { click_on 'Bearbeiten' }
    fill_in 'Wie oft?', with: 'daily'

    assert_field 'Vereinbarung erzeugen', checked: true

    click_on 'Begleitung aktualisieren', match: :first

    assert_text 'Begleitung wurde erfolgreich geändert.'

    within('.assignments-table') { click_on 'Bearbeiten' }
    click_on 'Herunterladen', match: :first
    pdf = load_pdf(page.body)

    assert_equal 1, pdf.page_count
    assert_match(/Ort, Datum: +Zürich, #{I18n.l pdf_date.to_date}/, pdf.pages.first.text)
    assert_match(/Wie oft\? +daily/, pdf.pages.first.text)

    # changing a field doesn't automatically update the PDF

    visit edit_group_assignment_path(group_assignment)

    assert_field 'Vereinbarung überschreiben', checked: false

    fill_in 'Wie oft?', with: 'weekly'
    click_on 'Begleitung aktualisieren', match: :first

    assert_text 'Begleitung wurde erfolgreich geändert.'

    within('.assignments-table') { click_on 'Bearbeiten' }
    click_on 'Herunterladen', match: :first
    pdf = load_pdf(page.body)

    assert_match(/Wie oft\? +daily/, pdf.pages.first.text)

    # request to update the PDF

    pdf_date = 3.days.from_now
    travel_to pdf_date

    visit edit_group_assignment_path(group_assignment)
    check 'Vereinbarung überschreiben'
    click_on 'Begleitung aktualisieren', match: :first

    assert_text 'Begleitung wurde erfolgreich geändert.'

    within('.assignments-table') { click_on 'Bearbeiten' }
    click_on 'Herunterladen', match: :first
    pdf = load_pdf(page.body)

    assert_match(/Ort, Datum: +Zürich, #{I18n.l pdf_date.to_date}/, pdf.pages.first.text)
    assert_match(/Wie oft\? +weekly/, pdf.pages.first.text)

    # make sure the download link is displayed on the group offer as well

    visit group_offer_path(group_offer)

    within('.assignments-table') { assert_link 'Herunterladen', count: 1 }
  end
end
