require 'application_system_test_case'

class GroupOffersTest < ApplicationSystemTestCase
  def setup
    @department_manager = create :department_manager
    @group_offer_category = create :group_offer_category
  end

  test 'new_group_offer_form' do
    login_as create(:user)
    visit new_group_offer_path

    fill_in 'Title', with: 'asdf'
    page.choose('group_offer_offer_type_internal_offer')
    page.choose('group_offer_offer_state_full')
    page.choose('group_offer_volunteer_state_internal_volunteer')
    select @group_offer_category.category_name, from: 'Group offer category'
    select @department_manager.department.first, from: 'Department'
    select @department_manager, from: 'Verantwortliche/r'
    select '2', from: 'Necessary volunteers'
    fill_in 'Description', with: 'asdf'
    page.check('group_offer_all')
    page.check('group_offer_regular')
    page.check('group_offer_weekend')
    fill_in 'Schedule details', with: 'asdf'

    click_button 'Create Group offer'
    assert page.has_text? 'Group offer was successfully created.'
  end

  test "department manager's offer belongs to their department" do
    department_manager = create :department_manager
    login_as department_manager
    visit new_group_offer_path

    fill_in 'Title', with: 'asdf'
    select @group_offer_category.category_name, from: 'Group offer category'
    click_button 'Create Group offer'
    assert page.has_text? 'Group offer was successfully created.'
    assert page.has_link? department_manager.department.first.contact.last_name
  end

  test 'category for a group offer is required' do
    login_as create(:user)
    visit new_group_offer_path

    click_button 'Create Group offer'
    assert page.has_text? 'Please review the problems below:'
    assert page.has_text? 'must exist'
  end

  test 'group offer can be deactivated' do
    group_offer = create :group_offer
    login_as create(:user)
    visit group_offers_path
    assert page.has_text? group_offer.title
    refute page.has_link? 'Activate'
    click_link 'Deactivate'

    assert page.has_text? group_offer.title
    assert page.has_link? 'Activate'
    refute page.has_link? 'Deactivate'
  end

  test 'group_offer_can_be_activated' do
    group_offer = create :group_offer, active: false
    login_as create(:user)
    visit group_offers_path
    assert page.has_text? group_offer.title
    assert page.has_link? 'Activate'
    click_link 'Activate'

    assert page.has_text? group_offer.title
    assert page.has_link? 'Deactivate'
    refute page.has_link? 'Activate'
  end

  test 'deleting volunteer from group offer creates log entry without an agreement' do
    login_as create(:user)
    volunteer = create :volunteer
    group_offer = create :group_offer, volunteers: [volunteer]

    visit volunteer_path(volunteer)
    assert page.has_text? 'Active group offers'
    assert page.has_link? group_offer.title
    refute page.has_text? 'Group offers log'

    visit edit_group_offer_path(group_offer)
    click_link 'Löschen'
    click_button 'Update Group offer'

    visit volunteer_path(volunteer)
    refute page.has_text? 'Active group offers'
    assert page.has_text? 'Group offers log'
    assert page.has_link? group_offer.title
    refute page.has_link? 'Download'
  end

  test 'modifying volunteer dates does not create a log entry' do
    login_as create(:user)
    volunteer = create :volunteer
    group_offer = create :group_offer, volunteers: [volunteer]

    visit volunteer_path(volunteer)
    assert page.has_text? 'Active group offers'
    assert page.has_link? group_offer.title
    refute page.has_text? 'Group offers log'
  end

  test 'deleting group offer creates log and does not crash volunteer show' do
    login_as create(:user)
    volunteer = create :volunteer
    group_offer = create :group_offer, volunteers: [volunteer]
    title = group_offer.title

    visit volunteer_path(volunteer)
    assert page.has_text? 'Active group offers'
    assert page.has_link? group_offer.title
    refute page.has_text? 'Group offers log'

    GroupOffer.last.destroy

    visit volunteer_path(volunteer)
    refute page.has_text? 'Active group offers'
    assert page.has_text? 'Group offers log'
    assert page.has_text? title
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
    assert page.has_link? volunteer1.contact.full_name
    assert page.has_link? volunteer2.contact.full_name

    Volunteer.find(volunteer1.id).destroy

    visit group_offer_path(group_offer)
    assert page.has_link? volunteer2.contact.full_name
    refute page.has_link? volunteer1.contact.full_name
  end

  test 'department_manager_has_group_assignment_select_dropdowns_in_edit_form_filled' do
    department_manager = create :department_manager
    volunteer_one = create :volunteer
    volunteer_two = create :volunteer
    group_offer = create :group_offer, group_offer_category: @group_offer_category,
      department: department_manager.department.first, group_assignments: [
        GroupAssignment.create(volunteer: volunteer_one),
        GroupAssignment.create(volunteer: volunteer_two)
      ]
    login_as department_manager
    visit edit_group_offer_path(group_offer)
    select_values = page.find_all('#volunteers .group_offer_group_assignments_volunteer select')
                        .map(&:value).map(&:to_i)
    assert select_values.include? volunteer_one.id
    assert select_values.include? volunteer_two.id
  end

  test 'department_manager cannot access group offer pages unless there is a department assigned' do
    department_manager = create :user, role: 'department_manager'
    login_as department_manager
    refute page.has_link? 'Gruppenangebote'
    visit group_offers_path
    assert page.has_text? 'You are not authorized to perform this action.'
    visit new_group_offer_path
    assert page.has_text? 'You are not authorized to perform this action.'
  end

  test 'volunteer collection on creation is present' do
    volunteer = create :volunteer
    login_as create(:user)
    visit new_group_offer_path
    select(@group_offer_category, from: 'Group offer category')
    fill_in 'Title', with: 'Title'
    page.choose('Internal volunteer')
    click_link 'Freiwillige hinzufügen'
    select(volunteer.full_name, from: 'Volunteer')
    click_button 'Create Group offer'
    assert page.has_text? 'Group offer was successfully created.'
  end

  test 'internal_external_volunteers_load_different_lists' do
    internal = create :volunteer_internal
    external = create :volunteer_external
    login_as create(:user)
    visit new_group_offer_path
    select(@group_offer_category, from: 'Group offer category')
    fill_in 'Title', with: 'Title'

    page.choose('Internal volunteer')
    click_link 'Freiwillige hinzufügen'
    select_values = page.find_all('#volunteers .group_offer_group_assignments_volunteer select')
                        .map(&:value).map(&:to_i)
    assert select_values.include? internal.id
    refute select_values.include? external.id

    page.choose('External volunteer')
    click_link 'Freiwillige hinzufügen'
    select_values = page.find_all('#volunteers .group_offer_group_assignments_volunteer select')
                        .map(&:value).map(&:to_i)
    refute select_values.include? internal.id
    assert select_values.include? external.id
  end

  test 'group_offers_on_edit_have_only_internal_or_external_volunteers' do
    internal = create :volunteer_with_user, :internal
    external = create :volunteer_external
    internal_group_offer = create :group_offer, volunteer_state: 'internal_volunteer'
    external_group_offer = create :group_offer, volunteer_state: 'external_volunteer'
    login_as create(:user)

    visit edit_group_offer_path(internal_group_offer)
    click_link 'Freiwillige hinzufügen'
    assert page.has_select?('Volunteer', text: internal.full_name)
    refute page.has_select?('Volunteer', text: external.full_name)

    visit edit_group_offer_path(external_group_offer)
    click_link 'Freiwillige hinzufügen'
    refute page.has_select?('Volunteer', text: internal.full_name)
    assert page.has_select?('Volunteer', text: external.full_name)
  end
end
