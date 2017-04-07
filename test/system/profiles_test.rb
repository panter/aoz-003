require 'application_system_test_case'

class ProfilesTest < ApplicationSystemTestCase
  def setup
    create :profileless
  end

  test 'when first login displays profile form' do
    visit new_user_session_path
    fill_in 'Email', with: 'newuser@example.com'
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

    assert page.has_text? 'Arbeitstage'
  end

  test 'when first login create profile works' do
    visit new_user_session_path
    fill_in 'Email', with: 'newuser@example.com'
    fill_in 'Password', with: 'asdfasdf'
    click_button 'Log in'

    assert page.has_current_path? new_profile_path

    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Muster'
    click_button 'Create Profile'

    newuser = User.last
    assert newuser.profile.present?
    assert_equal newuser.profile.first_name, 'Hans'
    assert_equal newuser.profile.last_name, 'Muster'
  end

  test 'when profile created it can be displayed' do
    visit new_user_session_path
    fill_in 'Email', with: 'newuser@example.com'
    fill_in 'Password', with: 'asdfasdf'
    click_button 'Log in'
    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Muster'
    click_button 'Create Profile'
    assert page.has_link? 'Hans Muster'
    click_link 'Hans Muster'
    assert page.has_text? 'First name'

    assert page.has_text? 'Last name'
    assert page.has_text? 'Days available'
  end
end
