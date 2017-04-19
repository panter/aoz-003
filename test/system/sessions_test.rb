require 'application_system_test_case'

class SessionsTest < ApplicationSystemTestCase
  setup do
    @superadmin = create :user_with_profile
  end

  test 'redirects to login page if not authenticated' do
    visit root_path

    assert page.has_current_path? new_user_session_path
    assert page.has_text? 'You need to sign in or sign up before continuing.'
  end

  test 'sign in with valid credentials' do
    visit new_user_session_path

    assert page.has_field? 'Email'

    fill_in 'Email', with: @superadmin.email
    fill_in 'Password', with: 'asdfasdf'
    click_on 'Log in'
    assert page.has_current_path? root_path
    assert page.has_text? 'Signed in successfully.'

    click_on 'Toggle navigation' if page.has_button? 'Toggle navigation'

    assert page.has_link? @superadmin.email
  end

  test 'sign out current user' do
    login_as @superadmin, scope: :user
    visit root_path

    # trigger hamburger on mobile views
    click_on 'Toggle navigation' if page.has_button? 'Toggle navigation'

    click_on @superadmin.email
    assert page.has_link? 'Logout'
    click_on 'Logout'

    assert page.has_current_path? new_user_session_path
    assert page.has_text? 'You need to sign in or sign up before continuing.'
  end
end
