require 'application_system_test_case'

class AdminResetUserPasswordTest < ApplicationSystemTestCase
  def setup
    @comon_pw = 'asdfasdf'
    @common_changed_pw = 'qwerqwer'
    @admin = create :superadmin, password: @comon_pw, email: 'admin_changing@example.com'
  end

  test 'can update other admins password and then log in with other admin' do
    login_as(@admin)
    other_admin = create :superadmin, password: @comon_pw, email: 'admin.to.change@example.com'
    update_users_password(other_admin, @common_changed_pw)
    sign_out_logged_in_user(@admin)
    form_login_user(other_admin, @common_changed_pw)
  end

  test 'can update department_managers password and then log in with department manager' do
    login_as(@admin)
    department_manager = create :department_manager, password: @comon_pw, email: 'dep.manager.to.change@example.com'
    update_users_password(department_manager, @common_changed_pw)
    sign_out_logged_in_user(@admin)
    form_login_user(department_manager, @common_changed_pw)
  end

  test 'can update social workers password and then log in with social worker' do
    login_as(@admin)
    social_worker = create :social_worker, password: @comon_pw, email: 'social.worker.to.change@example.com'
    update_users_password(social_worker, @common_changed_pw)
    sign_out_logged_in_user(@admin)
    form_login_user(social_worker, @common_changed_pw)
  end

  test 'Admin sets password for invited volunteer and then volunteer can login without accepting invitation' do
    volunteer = create :volunteer_internal, acceptance: :undecided
    volunteer.contact.update!(primary_email: 'volunteer@aoz.ch')
    volunteer.accepted!
    form_login_user(@admin, @comon_pw)
    update_users_password(volunteer.user, @common_changed_pw, email: 'volunteer@aoz.ch')
    sign_out_logged_in_user(@admin)
    form_login_user(volunteer.user, @common_changed_pw, email: 'volunteer@aoz.ch')
  end

  test 'logged in before volunteer can log in with password admin sets' do
    volunteer = create :volunteer_internal, acceptance: :undecided
    volunteer.contact.update!(primary_email: 'volunteer@aoz.ch')
    volunteer.accepted!
    visit root_path
    visit accept_user_invitation_url(invitation_token: volunteer.user.raw_invitation_token)
    fill_in 'Passwort', with: @comon_pw
    fill_in 'Passwort bestätigen', with: @comon_pw
    click_button 'Passwort setzen'
    assert_text 'Ihr Passwort wurde erfolgreich gesetzt und Sie sind jetzt angemeldet.'
    sign_out_logged_in_user(volunteer.user)
    form_login_user(@admin, @comon_pw, email: 'admin_changing@example.com')
    update_users_password(volunteer.user, @common_changed_pw, email: 'volunteer@aoz.ch')
    sign_out_logged_in_user(@admin)
    form_login_user(volunteer.user, @common_changed_pw, email: 'volunteer@aoz.ch')
  end

  def update_users_password(user, password, email: nil)
    visit edit_user_path(user)
    assert page.has_field? 'Email', with: email || user.email
    fill_in 'Passwort', with: password
    accept_confirm do
      click_button 'Login aktualisieren'
    end
    assert_text 'Profil wurde erfolgreich aktualisiert.'
  end

  def form_login_user(user, password, email: nil)
    fill_in 'Email', with: email || user.email
    fill_in 'Passwort', with: password
    click_button 'Anmelden'
    assert_text 'Erfolgreich angemeldet.'
    within '.navbar-top .nav.navbar-nav.navbar-right' do
      assert page.has_link? user.full_name
    end
  end

  def sign_out_logged_in_user(user)
    within '.navbar-top .nav.navbar-nav.navbar-right' do
      click_link user.full_name
      wait_for_ajax
      click_link 'Abmelden'
    end
  end
end
