require 'application_system_test_case'

class ProfilesTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @user_without_profile = create :user
    @social_worker = create :user, role: 'social_worker'
  end

  test 'when first login displays profile form' do
    visit new_user_session_path
    fill_in 'Email', with: @user_without_profile.email
    fill_in 'Password', with: 'asdfasdf'
    click_button 'Log in'

    assert page.has_current_path? new_profile_path
    assert page.has_text? 'New Profile'

    assert page.has_field? 'First name'
    assert page.has_field? 'Last name'
    assert page.has_field? 'Avatar'
    assert page.has_field? 'Street'
    assert page.has_field? 'Zip'
    assert page.has_field? 'City'
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

  test 'when profile created it can be displayed' do
    visit new_user_session_path
    fill_in 'Email', with: @user_without_profile.email
    fill_in 'Password', with: 'asdfasdf'
    click_button 'Log in'

    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Muster'
    click_button 'Create Profile'
    within '#menu' do
      assert page.has_link? @user_without_profile.email
      click_link @user_without_profile.email
      assert page.has_link? 'Show profile'
      click_link 'Show profile'
    end
    assert page.has_text? @user_without_profile.profile.contact.first_name
    assert page.has_text? @user_without_profile.profile.contact.last_name
  end

  test 'user can change the password from profile page' do
    login_as @user
    visit profile_path(@user.profile.id)

    click_link 'Edit login'

    assert page.has_field? 'Password'
    assert page.has_field? 'Email'
    assert page.has_field? 'Role'

    fill_in 'Password', with: 'abcdefghijk'
    fill_in 'Email', with: 'new@email.com'
    click_button 'Update login'

    user = User.find @user.id
    assert user.valid_password? 'abcdefghijk'
    assert_equal user.email, 'new@email.com'
  end

  test 'profileless user gets new profile link on show profile' do
    login_as @user_without_profile
    visit user_path(@user_without_profile)
    within '#menu' do
      click_link @user_without_profile.email
      assert page.has_link? 'Create profile'
      click_link 'Create profile'
    end
    assert page.has_text? 'New Profile'
  end

  test 'user cannot edit other users profile' do
    login_as @social_worker
    visit edit_profile_path(@user.profile.id)
    assert page.has_text? 'You are not authorized to perform this action.'
  end
end
