require 'application_system_test_case'

class ProfilesTest < ApplicationSystemTestCase
  def setup
    create :profile unless User.find_by email: 'superadmin@example.com'
    @superadmin = User.find_by email: 'superadmin@example.com'
    @noprofile = create :user_noprofile
  end

  test 'when first login displays profile form' do
    visit new_user_session_path
    fill_in 'Email', with: @noprofile.email
    fill_in 'Password', with: 'asdfasdf'
    click_button 'Log in'

    assert page.has_current_path? new_profile_path
    assert page.has_text? 'New profile'

    assert page.has_field? 'First name'
    assert page.has_field? 'Last name'
    assert page.has_field? 'Phone'
    assert page.has_field? 'Picture'
    assert page.has_field? 'Address'
    assert page.has_field? 'Profession'
    assert page.has_field? 'Monday'
    assert page.has_field? 'Tuesday'
    assert page.has_field? 'Wednesday'
    assert page.has_field? 'Thursday'
    assert page.has_field? 'Friday'

    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Muster'
    click_button 'Create Profile'

    assert page.has_current_path? profile_path(@noprofile.profile.id)
    assert page.has_text? 'Hans'
    assert page.has_text? 'Muster'
    assert page.has_text? 'Profile was successfully created.'
  end

  test 'when profile created it can be displayed' do
    visit new_user_session_path
    fill_in 'Email', with: @noprofile.email
    fill_in 'Password', with: 'asdfasdf'
    click_button 'Log in'
    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Muster'
    click_button 'Create Profile'
    assert page.has_link? 'Hans Muster'
    click_link 'Hans Muster'
    assert page.has_text? 'First name'

    assert page.has_text? 'Last name'
    assert page.has_text? 'Working days'
  end

  test 'user can change the password from profile page' do
    login_as @superadmin, scope: :user
    visit profile_path(@superadmin.profile.id)

    assert page.has_link? 'Change your password'
    click_link 'Change your password'

    assert page.has_field? 'Current password'
    assert page.has_field? 'New password'
    assert page.has_field? 'Confirm your new password'
    assert page.has_button? 'Change password'
    assert page.has_button? 'Cancel'

    fill_in 'Current password', with: 'asdfasdf'
    fill_in 'New password', with: 'abcdefghijk'
    fill_in 'Confirm your new password', with: 'abcdefghijk'
    click_button 'Change password'

    user = User.find @superadmin.id
    assert user.valid_password? 'abcdefghijk'
  end

  test 'user can change the email' do
    login_as @superadmin, scope: :user
    visit profile_path(@superadmin.profile.id)

    assert page.has_link? 'Change your email'
    click_link 'Change your email'

    assert page.has_field? 'New email'
    assert page.has_button? 'Change email'
    assert page.has_button? 'Cancel'

    fill_in 'New email', with: @superadmin.email
    click_button 'Change email'

    changed = User.find @superadmin.id
    assert_equal changed.id, @superadmin.id
  end
end
