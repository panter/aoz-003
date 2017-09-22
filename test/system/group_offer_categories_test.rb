require 'application_system_test_case'

class GroupOfferCategoriesTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    login_as @user
  end


  test 'create new group offer category and update it' do
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
    assert page.has_link? 'Edit'
    click_link 'Edit'

    assert page.has_text? 'Edit Group offer category'
    fill_in 'Category name', with: 'Nähen und Sticken'
    page.choose('group_offer_category_category_state_inactive')
    click_button 'Update Group offer category'
    assert page.has_text? 'Group offer category was successfully updated.'
    assert page.has_text? 'Nähen und Sticken'
    assert page.has_text? 'inactive'
  end
end
