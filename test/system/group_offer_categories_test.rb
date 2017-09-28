require 'application_system_test_case'

class GroupOfferCategoriesTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @department = create :department
    @department_manager = create :user, :with_departments
    @group_offer_category = create :group_offer_category, category_name: 'Schwimmen'
  end


  test 'superadmin can create new group offer' do
    login_as @user
    visit group_offers_path
    click_link 'Group offer categories'
    assert page.has_text? 'Group offer categories'
    click_link 'New Group offer category'

    fill_in 'Category name', with: 'Nähen'
    assert page.has_checked_field?('group_offer_category_category_state_active')
    click_button 'Create Group offer category'

    assert page.has_text? 'Group offer category was successfully created.'

    assert page.has_text? 'Category name'
    assert page.has_text? 'Nähen'
    assert page.has_text? 'Category state'
    assert page.has_text? 'active'
  end

  test 'superadmin can update a category' do
    login_as @user
    visit group_offer_categories_path

    assert page.has_text? 'Schwimmen'
    click_link 'Edit'
    fill_in 'Category name', with: 'Schwimmkurs'
    page.choose('group_offer_category_category_state_inactive')
    click_button 'Update Group offer category'
    assert page.has_text? 'Group offer category was successfully updated.'
    assert page.has_text? 'Schwimmkurs'
    assert page.has_text? 'inactive'
  end

  test 'department manager can create new group offer' do
    login_as @department_manager
    visit group_offers_path
    click_link 'Group offer categories'
    assert page.has_text? 'Group offer categories'
    click_link 'New Group offer category'

    fill_in 'Category name', with: 'Nähen'
    assert page.has_checked_field?('group_offer_category_category_state_active')
    click_button 'Create Group offer category'

    assert page.has_text? 'Group offer category was successfully created.'

    assert page.has_text? 'Category name'
    assert page.has_text? 'Nähen'
    assert page.has_text? 'Category state'
    assert page.has_text? 'active'
  end

  test 'department manager can update a category' do
    login_as @department_manager
    visit group_offer_categories_path

    assert page.has_text? 'Schwimmen'
    click_link 'Edit'
    fill_in 'Category name', with: 'Schwimmkurs für Anfänger'
    page.choose('group_offer_category_category_state_inactive')
    click_button 'Update Group offer category'
    assert page.has_text? 'Group offer category was successfully updated.'
    assert page.has_text? 'Schwimmkurs für Anfänger'
    assert page.has_text? 'inactive'
  end
end
