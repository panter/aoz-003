require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  setup do
    create :user
    @user = User.last
    visit new_user_session_path
    fill_in 'Email', with: 'superadmin@example.com'
    fill_in 'Password', with: 'asdfasdf'
    click_button 'Log in'
    visit new_user_path
  end

  test 'invalid superadmin information' do
    fill_in 'Email', with: ''
    select('', from: 'Role')
    click_button 'Create User'

    assert page.has_text? 'Please review the problems below:'
    assert page.has_text? "can't be blank"
    assert page.has_text? 'is not included in the list'

    assert_equal User.last.email, 'superadmin@example.com'
  end

  test 'invalid user role' do
    fill_in 'Email', with: 'superadmin@test.ch'
    select('', from: 'Role')
    click_button 'Create User'

    assert page.has_text? 'Please review the problems below:'
    assert page.has_text? 'is not included in the list'

    assert_equal User.last.email, 'superadmin@example.com'
  end

  test 'taken user email' do
    fill_in 'Email', with: 'superadmin@example.com'
    select('superadmin', from: 'Role')
    click_button 'Create User'

    assert page.has_text? 'Please review the problems below:'
    assert page.has_text? 'has already been taken'

    assert_equal User.last.email, 'superadmin@example.com'
  end

  test 'valid superadmin registration' do
    fill_in 'Email', with: 'superadmin@test.ch'
    select('superadmin', from: 'Role')
    click_button 'Create User'

    assert page.has_text? 'Invitation sent to superadmin@test.ch'

    assert_equal User.last.email, 'superadmin@test.ch'
  end

  test 'should redirect create new user creation when not logged in' do
    click_link 'superadmin@example.com'
    click_link 'Logout'

    links = [new_user_path, users_path, user_path(@user)]
    links.each do |link|
      visit link
      assert page.has_current_path? new_user_session_path
      assert page.has_text? 'You need to sign in or sign up before continuing.'
    end
  end
end
