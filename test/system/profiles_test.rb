require 'application_system_test_case'

class ProfilesTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @user_without_profile = create :user, :without_profile
    @social_worker = create :user, role: 'social_worker'
  end

  test 'when first login displays profile form' do
    visit new_user_session_path
    fill_in 'Email', with: @user_without_profile.email
    fill_in 'Passwort', with: 'asdfasdf'
    click_button 'Anmelden'

    assert_current_path new_profile_path
    assert_text 'Profil erfassen'

    assert_field 'Vorname'
    assert_field 'Nachname'
    assert_field 'Foto'
    assert_field 'Strasse'
    assert_field 'PLZ'
    assert_field 'Ort'
    assert_field 'Mailadresse', with: @user_without_profile.email
    assert_field 'Beruf'
    assert_field name: 'profile[flexible]'
    assert_field name: 'profile[morning]'
    assert_field name: 'profile[afternoon]'
    assert_field name: 'profile[evening]'
    assert_field name: 'profile[workday]'
    assert_field name: 'profile[weekend]'
    assert_field 'Genauere Angaben'

    fill_in 'Vorname', with: 'Hans'
    fill_in 'Nachname', with: 'Muster'
    fill_in 'Mailadresse', with: FFaker::Internet.unique.email
    fill_in 'Telefonnummer', with: '123456789'
    page.check(name: 'profile[morning]')

    click_button 'Profil erfassen'
    @user_without_profile.reload

    assert_text 'Profil wurde erfolgreich erstellt.'
    assert_current_path profile_path(@user_without_profile.profile)

    assert_text 'Hans'
    assert_text 'Muster'

    assert_text 'Nein Flexibel'
    assert_text 'Ja Morgens'
    assert_text 'Nein Nachmittags'
    assert_text 'Nein Abends'
    assert_text 'Nein Werktags'
    assert_text 'Nein Wochenende'
  end

  test 'when_profile_created_it_can_be_displayed' do
    visit new_user_session_path
    fill_in 'Email', with: @user_without_profile.email
    fill_in 'Passwort', with: 'asdfasdf'
    click_button 'Anmelden'

    fill_in 'Vorname', with: 'Hans'
    fill_in 'Nachname', with: 'Muster'
    fill_in 'Mailadresse', with: FFaker::Internet.unique.email
    fill_in 'Telefonnummer', with: '123456789'

    click_button 'Profil erfassen'
    @user_without_profile.reload

    within '.navbar-top' do
      click_link I18n.t("role.#{@user_without_profile.role}"), href: '#'
    end

    click_link 'Profil bearbeiten', match: :first
    click_link 'Zurück'
    assert_text @user_without_profile.profile.contact.first_name
    assert_text @user_without_profile.profile.contact.last_name
  end

  test 'profileless user gets new profile link on show profile' do
    login_as @user_without_profile
    visit user_path(@user_without_profile)
    within '#menu' do
      click_link @user_without_profile.email
      assert_link 'Profil erfassen'
      click_link 'Profil erfassen'
    end
    assert_text 'Profil erfassen'
  end

  test 'user cannot edit other users profile' do
    login_as @social_worker
    visit edit_profile_path(@user.profile.id)
    assert_text 'Sie sind nicht berechtigt diese Aktion durchzuführen.'
  end

  test 'new profile has no secondary phone field' do
    visit new_user_session_path
    fill_in 'Email', with: @user_without_profile.email
    fill_in 'Passwort', with: 'asdfasdf'
    click_button 'Anmelden'
    assert_text 'Profil erfassen'
    refute_text 'Telefonnummer 2', wait: 0
  end

  test 'profile has no secondary phone field' do
    login_as @user
    visit profile_path(@user.profile.id)
    assert_text @user.full_name
    refute_text 'Telefonnummer 2', wait: 0
  end

  test 'user without profile gets redirected to profile form' do
    login_as @user_without_profile
    visit root_path

    assert_text 'Profil erfassen'
    assert_text 'Bitte füllen Sie Ihr Profil aus um die Applikation zu verwenden.'
    refute_link 'Freiwillige', wait: 0
  end

  test 'volunteer without profile does not get redirected to profile form' do
    user = create :user_volunteer, volunteer: create(:volunteer), profile: nil
    login_as user
    visit root_path

    assert_link 'Freiwillige'
    refute_text 'Profil erfassen', wait: 0
  end

  test 'superadmin with profile does not get redirected to profile form' do
    login_as @user
    visit root_path

    assert_link 'Freiwillige'
    refute_text 'Profil erfassen', wait: 0
  end
end
