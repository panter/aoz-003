require 'application_system_test_case'

class SessionsTest < ApplicationSystemTestCase
  setup do
    @user = create :user
  end

  test 'redirects to login page if not authenticated' do
    visit root_path

    assert page.has_current_path? new_user_session_path
    assert page.has_text? 'You need to sign in or sign up before continuing.'
  end

  test 'sign in with valid credentials' do
    visit new_user_session_path

    assert page.has_field? 'Email'

    fill_in 'Email', with: @user.email
    fill_in 'Password', with: 'asdfasdf'
    click_button 'Log in'

    assert page.has_text? 'Signed in successfully.'
    assert page.has_link? @user.email
  end

  test 'sign out current user' do
    login_as @user
    visit root_path
    click_link @user.email
    assert page.has_link? 'Logout'
    click_link 'Logout'

    assert page.has_current_path? new_user_session_path
    assert page.has_text? 'You need to sign in or sign up before continuing.'
  end
end
