require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  setup do
    @emails = ActionMailer::Base.deliveries
    @emails.clear
    @user = create :user, email: 'superadmin@example.com'
    login_as @user
    visit new_user_path
  end

  test 'invalid_superadmin_information' do
    fill_in 'Email', with: ''
    select '', from: 'Rolle'

    assert_no_difference 'User.count' do
      accept_prompt do
        click_button 'Benutzer/in erstellen'
      end
      assert page.has_text? 'Es sind Fehler aufgetreten. Bitte überprüfen Sie die rot markierten Felder.'
      assert page.has_text? 'darf nicht leer sein'
      assert page.has_text? 'ist nicht in der Liste enthalten'
    end
  end

  test 'invalid user role' do
    fill_in 'Email', with: 'superadmin@test.ch'
    select '', from: 'Rolle'

    assert_no_difference 'User.count' do
      accept_prompt do
        click_button 'Benutzer/in erstellen'
      end
      assert page.has_text? 'Es sind Fehler aufgetreten. Bitte überprüfen Sie die rot markierten Felder.'
      assert page.has_text? 'ist nicht in der Liste enthalten'
    end
  end

  test 'taken user email' do
    fill_in 'Email', with: 'superadmin@example.com'
    select 'Superadmin', from: 'Rolle'

    assert_no_difference 'User.count' do
      accept_prompt do
        click_button 'Benutzer/in erstellen'
      end
      assert page.has_text? 'Es sind Fehler aufgetreten. Bitte überprüfen Sie die rot markierten Felder.'
      assert page.has_text? 'ist schon vergeben'
    end
  end

  test 'valid superadmin registration' do
    fill_in 'Email', with: 'superadmin@test.ch'
    select 'Superadmin', from: 'Rolle'

    assert_difference 'User.count', 1 do
      accept_prompt do
        click_button 'Benutzer/in erstellen'
      end
      assert page.has_text? 'Einladung wurde an superadmin@test.ch verschickt.'
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.last
    assert_equal 'superadmin@test.ch', email['to'].to_s
  end

  test 'superadmin can destroy social worker' do
    create :user, role: 'social_worker'
    visit users_path

    assert page.has_link? 'Löschen'
  end

  test 'superadmin can destroy other superadmin' do
    create :user, role: 'superadmin'
    visit users_path

    assert page.has_link? 'Löschen'
  end

  test 'superadmin can not destroy itself' do
    visit users_path

    within page.find('tr', text: @user.full_name) do
      refute page.has_link? 'Löschen'
    end
  end

  test 'accepted_volunteer_becomes_a_user' do
    volunteer = create :volunteer, acceptance: :undecided

    visit edit_volunteer_path(volunteer.id)
    assert page.has_text? volunteer.full_name
    find("option[value='accepted']").click
    assert_difference 'User.count', 1 do
      first(:button, 'Freiwillige/n aktualisieren').click
    end
    assert page.has_text? "Einladung wurde an #{volunteer.contact.primary_email} verschickt."
    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.last
    volunteer.reload
    assert_equal volunteer.contact.primary_email, volunteer.user.email
  end

  test 'filter_users_by_role' do
    department_manager = create :department_manager
    social_worker = create :social_worker
    user_volunteer = create(:volunteer).user

    visit users_path

    assert page.has_link? @user.full_name
    assert page.has_link? department_manager.full_name
    assert page.has_link? social_worker.full_name
    assert page.has_link? user_volunteer.full_name

    within '.section-navigation' do
      click_link 'Rolle'
      click_link 'Superadmin'
    end
    visit current_url
    within 'tbody' do
      assert page.has_link? @user.full_name
      refute page.has_link? department_manager.full_name
      refute page.has_link? social_worker.full_name
      refute page.has_link? user_volunteer.full_name
    end

    within '.section-navigation' do
      click_link 'Rolle: Superadmin'
      click_link 'Freiwillige/r'
    end
    visit current_url
    within 'tbody' do
      refute page.has_link? @user.full_name
      refute page.has_link? department_manager.full_name
      refute page.has_link? social_worker.full_name
      assert page.has_link? user_volunteer.full_name
    end
  end

  test 'user_index_has_valid_links_for_users_without_profile' do
    superadmin_no_profile = create :user, :without_profile
    department_manager_no_profile = create :user, :without_profile, :department_manager
    social_worker_no_profile = create :user, :without_profile, :social_worker
    volunteer_no_profile = create(:volunteer).user

    visit users_path
    assert page.has_link? superadmin_no_profile.email
    click_link superadmin_no_profile.email
    assert page.has_text? 'Superadmin'

    visit users_path
    assert page.has_link? department_manager_no_profile.email
    click_link department_manager_no_profile.email
    assert page.has_text? 'Freiwilligenverantwortliche/r'

    visit users_path
    assert page.has_link? social_worker_no_profile.email
    click_link social_worker_no_profile.email
    assert page.has_text? 'Sozialarbeiter/in'

    visit users_path
    click_link volunteer_no_profile.full_name

    assert page.has_field? 'Vorname', with: volunteer_no_profile.volunteer.contact.first_name
    assert page.has_field? 'Nachname', with: volunteer_no_profile.volunteer.contact.last_name
  end

  test 'volunteer_can_change_password' do
    volunteer = create :volunteer
    volunteer_password = '123456'
    volunteer.user.update(password: volunteer_password)
    volunteer.user.accept_invitation!

    login_as volunteer.user
    visit root_path

    click_on volunteer.user
    click_on 'Login bearbeiten'
    fill_in 'Passwort', with: volunteer_password
    click_on 'Login aktualisieren'

    assert_text "#{volunteer} Bearbeiten Ausdrucken Persönlicher Hintergrund"

    click_on volunteer.user
    click_on 'Abmelden'
    fill_in 'Email', with: volunteer.user.email
    fill_in 'Passwort', with: volunteer_password
    click_on 'Anmelden'

    assert_text "#{volunteer} Bearbeiten Ausdrucken Persönlicher Hintergrund"
  end

  test 'superadmin can change password of other users' do
    roles = User::ROLES.dup
    users = []
    (roles - ['superadmin']).each do |role|
      user =
        if role == 'volunteer'
          create(:volunteer).user
        else
          create(:user)
        end

      user.update role: role
      users << user
    end

    users.each do |user|
      visit users_path

      within "tr##{ActionView::RecordIdentifier.dom_id user}" do
        click_on 'Bearbeiten'
      end
      fill_in 'Passwort', with: '123456'
      page.accept_alert do
        click_on 'Login aktualisieren'
      end

      assert_text 'Profil wurde erfolgreich aktualisiert.'
    end
  end
end
