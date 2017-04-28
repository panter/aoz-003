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
    assert page.has_field? name: 'profile[monday]'
    assert page.has_field? name: 'profile[tuesday]'
    assert page.has_field? name: 'profile[wednesday]'
    assert page.has_field? name: 'profile[thursday]'
    assert page.has_field? name: 'profile[friday]'

    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Muster'

    page.check(name: 'profile[monday]')
    click_button 'Create Profile'

    assert page.has_current_path? profile_path(@user_without_profile.profile.id)
    assert page.has_text? 'Hans'
    assert page.has_text? 'Muster'
    assert page.has_text? 'Profile was successfully created.'
    assert page.has_selector?('table > tbody td:nth-child(1) i.glyphicon-ok')
    refute page.has_selector?('table > tbody td:nth-child(2) i.glyphicon-ok')
    assert page.has_selector?('table > tbody td:nth-child(2) i.glyphicon-remove')
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
    click_button 'Update User'

    user = User.find @user_with_profile.id
    assert user.valid_password? 'abcdefghijk'
    assert_equal user.email, 'new@email.com'
  end
end
