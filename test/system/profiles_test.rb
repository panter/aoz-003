require 'application_system_test_case'

class ProfilesTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user_with_profile
    @noprofile = create :user
  end

  test 'when first login displays profile form' do
    visit new_user_session_path
    fill_in 'Email', with: @noprofile.email
    fill_in 'Password', with: 'asdfasdf'
    click_on 'Log in'

    assert page.has_current_path? new_profile_path
    assert page.has_text? 'New profile'

    assert page.has_field? 'First name'
    assert page.has_field? 'Last name'
    assert page.has_field? 'Phone'
    assert page.has_field? 'Avatar'
    assert page.has_field? 'Address'
    assert page.has_field? 'Profession'
    assert page.has_field? 'Monday'
    assert page.has_field? 'Tuesday'
    assert page.has_field? 'Wednesday'
    assert page.has_field? 'Thursday'
    assert page.has_field? 'Friday'

    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Muster'
    click_on 'Create Profile'

    assert page.has_current_path? profile_path(@noprofile.profile.id)
    assert page.has_text? 'Hans'
    assert page.has_text? 'Muster'
    assert page.has_text? 'Profile was successfully created.'
  end

  test 'when profile created it can be displayed' do
    visit new_user_session_path
    fill_in 'Email', with: @noprofile.email
    fill_in 'Password', with: 'asdfasdf'
    click_on 'Log in'

    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Muster'
    click_on 'Create Profile'

    click_on 'Toggle navigation' if page.has_button? 'Toggle navigation'

    assert page.has_link? @noprofile.email

    click_link @noprofile.email
    assert page.has_link? 'Show profile'

    click_on 'Show profile'

    assert page.has_text? 'My Profile'
    assert page.has_text? 'Information'
    assert page.has_text? @noprofile.profile.first_name
    assert page.has_text? @noprofile.profile.last_name
  end

  test 'user can change the password from profile page' do
    login_as @superadmin, scope: :user
    visit profile_path(@superadmin.profile.id)

    click_on 'Change your login'

    assert page.has_field? 'Password'
    assert page.has_field? 'Email'
    assert page.has_field? 'Role'

    fill_in 'Password', with: 'abcdefghijk'
    fill_in 'Email', with: 'new@email.com'
    click_on 'Update User'

    user = User.find @superadmin.id
    assert user.valid_password? 'abcdefghijk'
    assert_equal user.email, 'new@email.com'
  end
end
