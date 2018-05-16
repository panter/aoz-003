require 'application_system_test_case'

class SessionsTest < ApplicationSystemTestCase
  setup do
    @user = create :user
  end

  test 'redirects to login page if not authenticated' do
    visit root_path

    assert_current_path new_user_session_path
    assert_text 'Sie müssen sich anmelden oder registrieren, bevor Sie fortfahren können.'
  end

  test 'sign in with valid credentials' do
    visit volunteers_path

    assert_field 'Email'

    fill_in 'Email', with: @user.email
    fill_in 'Passwort', with: 'asdfasdf'
    click_button 'Anmelden'

    assert_text 'Erfolgreich angemeldet.'
    assert_text 'Freiwillige/n erfassen'

    within '.navbar-top' do
      assert_link I18n.t("role.#{@user.role}"), href: '#'
    end
  end

  test 'sign out current user' do
    login_as @user
    visit root_path
    within '.navbar-top' do
      click_link I18n.t("role.#{@user.role}"), href: '#'
    end
    assert_link 'Abmelden'
    click_link 'Abmelden'

    assert_current_path new_user_session_path
    assert_text 'Erfolgreich abgemeldet.'
  end
end
