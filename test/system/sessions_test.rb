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
    within '.navbar-top' do
      assert page.has_link? I18n.t("role.#{@user.role}"), href: '#'
    end
  end

  test 'sign out current user' do
    login_as @user
    visit root_path
    within '.navbar-top' do
      click_link I18n.t("role.#{@user.role}"), href: '#'
    end
    assert page.has_link? 'Abmelden'
    click_link 'Abmelden'

    assert page.has_current_path? new_user_session_path
    assert page.has_text? 'You need to sign in or sign up before continuing.'
  end
end
