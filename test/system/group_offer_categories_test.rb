require 'application_system_test_case'

class GroupOfferCategoriesTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    login_as @user
  end


  test 'create new group offer category and update it' do
    visit new_group_offer_category_path
    click_button 'Group offer categories'
    click_button 'New Group offer category'

    fill_in 'Category name', with: 'Nähen'
    assert page.has_select? 'Category state', selected: 'active'
    click_button 'Create Group offer category'

    assert page.has_text? 'Group offer category was successfully created.'

    within '.collapse .table-responsive' do
      assert page.has_text? 'Category name'
      assert page.has_text? 'Nähen'
      assert page.has_text? 'Category state'
      assert page.has_text? 'active'
      assert page.has_link? 'Edit'
      click_link 'Edit'
    end

    fill_in 'Category name', with: 'Nähen und Sticken'
    page.choose('group_offer_category_category_state_inactive')
    click_button 'Update Group offer category'
    assert page.has_text? 'Group offer category was successfully updated.'
  end
end
