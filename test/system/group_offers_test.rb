require 'application_system_test_case'

class GroupOffersTest < ApplicationSystemTestCase
  def setup
    create :department
  end

  test 'new group offer form' do
    login_as create(:user)
    visit new_group_offer_path

    fill_in 'Title', with: 'asdf'
    page.choose('group_offer_offer_type_internal_offer')
    page.choose('group_offer_offer_state_full')
    page.choose('group_offer_volunteer_state_internal_volunteer')
    select Department.first.contact.last_name, from: 'Department'
    select '2', from: 'Necessary volunteers'
    select 'Manager of volunteer group', from: 'Volunteer responsible'
    fill_in 'Description', with: 'asdf'
    page.check('group_offer_all')
    page.check('group_offer_regular')
    page.check('group_offer_weekend')
    fill_in 'Date time', with: 'asdf'

    click_button 'Create Group offer'
    assert page.has_text? 'Group offer was successfully created.'
  end

  test "department manager's offer belongs to their department" do
    department_manager = create :user, :with_departments
    login_as department_manager
    visit new_group_offer_path

    click_button 'Create Group offer'
    assert page.has_text? 'Group offer was successfully created.'
    assert page.has_text? department_manager.department.first.contact.last_name
  end
end
