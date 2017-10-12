require 'application_system_test_case'

class GroupOffersTest < ApplicationSystemTestCase
  def setup
    @department = create :department
    @group_offer_category = create :group_offer_category
  end

  test 'new group offer form' do
    login_as create(:user)
    visit new_group_offer_path

    fill_in 'Title', with: 'asdf'
    page.choose('group_offer_offer_type_internal_offer')
    page.choose('group_offer_offer_state_full')
    page.choose('group_offer_volunteer_state_internal_volunteer')
    select @group_offer_category.category_name, from: 'Group offer category'
    select @department.contact.last_name, from: 'Department'
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
    department_manager = create :user, :with_departments
    login_as department_manager
    visit new_group_offer_path

    fill_in 'Title', with: 'asdf'
    select @group_offer_category.category_name, from: 'Group offer category'
    click_button 'Create Group offer'
    assert page.has_text? 'Group offer was successfully created.'
    assert page.has_text? department_manager.department.first.contact.last_name
  end

  test 'category for a group offer is required' do
    login_as create(:user)
    visit new_group_offer_path

    click_button 'Create Group offer'
    assert page.has_text? 'Please review the problems below:'
    assert page.has_text? 'must exist'
  end

  test 'archived group offers are not indexed' do
    group_offer = create :group_offer, active: false
    login_as create(:user)
    visit group_offers_path
    refute page.has_text? group_offer.title
    visit archived_group_offers_path
    assert page.has_text? group_offer.title
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
    visit group_offers_path
    refute page.has_text? group_offer.title
  end

  test 'group offer can be activated' do
    group_offer = create :group_offer, active: false
    login_as create(:user)
    visit archived_group_offers_path
    assert page.has_text? group_offer.title
    assert page.has_link? 'Activate'
    click_link 'Activate'

    assert page.has_text? group_offer.title
    assert page.has_link? 'Deactivate'
    refute page.has_link? 'Activate'
    visit archived_group_offers_path
    refute page.has_text? group_offer.title
  end

  test 'deleting volunteer from group offer creates log entry' do
    login_as create(:user)
    volunteer = create :volunteer
    user_volunteer = create :user_volunteer, volunteer: volunteer
    group_offer = create :group_offer, volunteers: [volunteer]

    visit volunteer_path(volunteer)
    assert page.has_text? 'Group offers'
    assert page.has_link? group_offer.title
    refute page.has_text? 'Group offers log'

    visit edit_group_offer_path(group_offer)
    click_link 'Remove volunteer'
    click_button 'Update Group offer'

    visit volunteer_path(volunteer)
    assert page.has_text? 'Group offers log'
    assert page.has_link? group_offer.title
  end

  test 'modifying volunteer dates creates log entry' do
    login_as create(:user)
    volunteer = create :volunteer
    user_volunteer = create :user_volunteer, volunteer: volunteer
    group_offer = create :group_offer, volunteers: [volunteer]

    visit volunteer_path(volunteer)
    assert page.has_text? 'Group offers'
    assert page.has_link? group_offer.title
    refute page.has_text? 'Group offers log'

    group_offer.group_assignments.last.update(start_date: 7.months.ago, end_date: 2.months.ago)

    visit volunteer_path(volunteer)
    assert page.has_text? 'Group offers log'
    assert page.has_link? group_offer.title, count: 2

    group_offer.group_assignments.last.update(start_date: 6.months.ago, end_date: 3.months.ago)

    visit volunteer_path(volunteer)
    assert page.has_text? 'Group offers log'
    assert page.has_link? group_offer.title, count: 3
  end
end
