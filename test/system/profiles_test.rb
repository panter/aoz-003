require 'application_system_test_case'

class ProfilesTest < ApplicationSystemTestCase
  def setup
    @user_with_profile = create :user_with_profile
    @user_without_profile = create :user
  end

  test 'when first login displays profile form' do
    visit new_user_session_path
    fill_in 'Email', with: @user_without_profile.email
    fill_in 'Password', with: 'asdfasdf'
    click_button 'Log in'

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
    click_button 'Create Profile'

    assert page.has_current_path? profile_path(@user_without_profile.profile.id)
    assert page.has_text? 'Hans'
    assert page.has_text? 'Muster'
    assert page.has_text? 'Profile was successfully created.'
  end

  test 'when profile created it can be displayed' do
    visit new_user_session_path
    fill_in 'Email', with: @user_without_profile.email
    fill_in 'Password', with: 'asdfasdf'
    click_button 'Log in'

    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Muster'
    click_button 'Create Profile'

    assert page.has_link? @user_without_profile.email

    click_link @user_without_profile.email

    assert page.has_link? 'Show profile'

    click_link 'Show profile'

    assert page.has_text? 'My profile'
    assert page.has_text? @user_without_profile.profile.first_name
    assert page.has_text? @user_without_profile.profile.last_name
  end

  test 'user can change the password from profile page' do
    login_as @user_with_profile
    visit profile_path(@user_with_profile.profile.id)

    click_link 'Change your login'

    assert page.has_field? 'Password'
    assert page.has_field? 'Email'
    assert page.has_field? 'Role'

    fill_in 'Password', with: 'abcdefghijk'
    fill_in 'Email', with: 'new@email.com'
    click_button 'Update user'

    user = User.find @user_with_profile.id
    assert user.valid_password? 'abcdefghijk'
    assert_equal user.email, 'new@email.com'
  end
end
