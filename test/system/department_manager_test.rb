require 'application_system_test_case'

class DepartmentManagerTest < ApplicationSystemTestCase
  def setup
    @department_manager = create :department_manager, :with_clients
    login_as @department_manager
  end

  test 'when updates user login, cannot see role field' do
    visit edit_user_path(@department_manager)
    assert_not page.has_field? 'Role'
  end

  test 'does not have navbar links to users' do
    visit user_path(@department_manager.id)
    assert_not page.has_link? 'Benutzer/innen'
  end

  test 'has a navbar link to clients page' do
    visit user_path(@department_manager.id)
    assert page.has_link? 'Klient/innen'
  end

  test 'can see his clients' do
    visit clients_path
    @department_manager.clients.each do |client|
      assert page.has_text? client.contact.first_name
      assert page.has_text? client.contact.last_name
      assert page.has_link? href: client_path(client.id)
    end
  end

  test 'can see a group offer volunteer and return to the group offer' do
    volunteer = create :volunteer, registrar: @department_manager
    group_offer = create :group_offer, volunteers: [volunteer],
      department: @department_manager.department.first
    visit volunteer_path(volunteer)
    assert page.has_link? group_offer.title
    visit group_offer_path(group_offer)
    assert page.has_link? volunteer.contact.full_name
  end

  test 'without department has read-only access to group_offers' do
    department_manager_without_department = create :department_manager_without_department
    group_offer = create :group_offer, creator: department_manager_without_department

    login_as department_manager_without_department
    visit group_offers_path

    assert page.has_text? group_offer.title
    refute page.has_field? 'Bezeichnung', with: 'new title'
  end

  test 'can edit group_offers in her department' do
    group_offer = create :group_offer, department: @department_manager.department.last

    visit group_offers_path
    assert page.has_text? group_offer.title

    click_link 'Bearbeiten'
    fill_in 'Bezeichnung', with: 'new title'
    click_button 'Gruppenangebot aktualisieren'
    assert page.has_text? 'Gruppenangebot wurde erfolgreich geändert.'
    assert page.has_field? 'Bezeichnung', with: 'new title'
  end

  test 'has read-only access to group_offers from another department' do
    group_offer = create :group_offer

    refute @department_manager.department.include?(group_offer.department)

    visit group_offers_path

    assert page.has_text? group_offer.title
    refute page.has_field? 'Bezeichnung', with: 'new title'

    visit group_offer_path group_offer
    assert page.has_text? group_offer.title
    refute page.has_button? 'Gruppenangebot aktualisieren'

    visit edit_group_offer_path group_offer
    assert page.has_text? I18n.t('not_authorized')
  end

  test "without deparment has read-only access to group_assignments" do
    department_manager_without_department = create :department_manager_without_department
    group_offer = create :group_offer
    group_assignment = create :group_assignment, group_offer: group_offer
    3.times { create :terminated_group_assignment, group_offer: create(:group_offer) }

    login_as department_manager_without_department

    visit group_offers_path
    assert page.has_link? 'Beendete Einsätze'

    click_link 'Beendete Einsätze'
    assert page.has_text? 'Beendete Gruppeneinsätze'

    click_link 'Filter aufheben'

    GroupAssignment.ended.each do |assignment|
      assert page.has_css? "tr##{dom_id assignment}"
    end

    assert page.has_link? 'Anzeigen'
    refute page.has_link? 'Bearbeiten'
    refute page.has_link? 'Beendigungsformular'
    refute page.has_link? 'Freiwillige/n beenden'

    visit group_offer_path group_offer
    within '.table-responsive.assignments-table' do
      refute page.has_link? 'Bearbeiten'
    end

    visit group_offers_path

    assert page.has_text? group_offer.title
    assert page.has_link? 'Anzeigen'
    refute page.has_link? 'Bearbeiten'

    visit group_offer_path group_offer
    assert page.has_text? group_offer.title
    refute page.has_button? 'Gruppenangebot aktualisieren'
    within '.table-responsive.assignments-table' do
      refute page.has_link? 'Bearbeiten'
    end

    visit edit_group_offer_path group_offer
    assert page.has_text? I18n.t('not_authorized')

    visit new_group_offer_path
    assert page.has_text? I18n.t('not_authorized')

    visit edit_group_assignment_path group_assignment
    assert page.has_text? I18n.t('not_authorized')
  end

  test 'can edit group_assignments in her department' do
    group_offer = create :group_offer, department: @department_manager.department.last
    group_assignment = create :group_assignment, group_offer: group_offer

    login_as @department_manager
    visit edit_group_offer_path group_offer

    within '.table-responsive.assignments-table' do
      assert page.has_link? 'Bearbeiten'

      click_link 'Bearbeiten'
    end

    assert page.has_text? 'Gruppenangebots Einsatz bearbeiten'

    fill_in 'Bemerkungen', with: 'Test'
    click_button 'Begleitung aktualisieren', match: :first
    assert page.has_text? 'Begleitung wurde erfolgreich geändert.'
  end

  test 'has read-only access to group_assigments from another department' do
    group_offer = create :group_offer
    group_assignment = create :group_assignment, group_offer: group_offer
    3.times { create :terminated_group_assignment, group_offer: create(:group_offer) }

    refute @department_manager.department.include?(group_offer.department)

    login_as @department_manager

    visit group_offers_path
    assert page.has_link? 'Beendete Einsätze'

    click_link 'Beendete Einsätze'
    assert page.has_text? 'Beendete Gruppeneinsätze'

    click_link 'Filter aufheben'

    GroupAssignment.ended.each do |assignment|
      assert page.has_css? "tr##{dom_id assignment}"
    end

    assert page.has_link? 'Anzeigen'
    refute page.has_link? 'Bearbeiten'
    refute page.has_link? 'Beendigungsformular'
    refute page.has_link? 'Freiwillige/n beenden'

    visit group_offer_path group_offer
    within '.table-responsive.assignments-table' do
      refute page.has_link? 'Bearbeiten'
    end

    visit group_offers_path

    assert page.has_text? group_offer.title
    assert page.has_link? 'Anzeigen'
    refute page.has_link? 'Bearbeiten'

    visit group_offer_path group_offer
    assert page.has_text? group_offer.title
    refute page.has_button? 'Gruppenangebot aktualisieren'
    within '.table-responsive.assignments-table' do
      refute page.has_link? 'Bearbeiten'
    end

    visit edit_group_offer_path group_offer
    assert page.has_text? I18n.t('not_authorized')

    visit new_group_offer_path
    refute page.has_text? I18n.t('not_authorized')

    visit edit_group_assignment_path group_assignment
    assert page.has_text? I18n.t('not_authorized')
  end

  test 'department_manager_has_no_destroy_and_feedback_links_on_volunteer_show' do
    volunteer = create :volunteer, registrar: @department_manager
    group_offer = create :group_offer, volunteers: [volunteer],
      department: @department_manager.department.first
    assignment = create :assignment, volunteer: volunteer
    visit volunteer_path(volunteer)
    assert page.has_link? group_offer.title
    assert page.has_link? assignment.client.contact.full_name
    refute page.has_link? 'Löschen'
    refute page.has_link? 'Feedback erfassen'
    refute page.has_link? 'Feedback Liste'
  end
end
