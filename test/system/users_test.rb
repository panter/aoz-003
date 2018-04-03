require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  setup do
    @emails = ActionMailer::Base.deliveries
    @emails.clear
    @user = create :user, email: 'superadmin@example.com'
    login_as @user
    visit new_user_path
  end

  test 'invalid superadmin information' do
    fill_in 'Email', with: ''
    select '', from: 'Rolle'

    assert_no_difference 'User.count' do
      accept_prompt do
        click_button 'Benutzer/in erstellen'
      end
      assert page.has_text? 'Bitte überprüfen Sie folgende Probleme:'
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
      assert page.has_text? 'Bitte überprüfen Sie folgende Probleme:'
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
      assert page.has_text? 'Bitte überprüfen Sie folgende Probleme:'
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

  test "superadmin can't destroy superadmin" do
    create :user, role: 'superadmin'
    visit users_path

    assert_not page.has_link? 'Löschen'
  end

  test 'accepted volunteer becomes a user' do
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
    assert_equal volunteer.contact.primary_email, email['to'].to_s
  end

  test 'superadmin can edit only their password' do
    other_superadmin = create :user
    department_manager = create :department_manager
    social_worker = create :social_worker
    volunteer = create :user_volunteer
    other_users = [other_superadmin, department_manager, social_worker, volunteer]

    other_users.each do |user|
      visit edit_user_path(user)
      refute page.has_field? 'Passwort'
    end

    visit edit_user_path(@user)
    assert page.has_field? 'Passwort'
  end

  test 'filter users by role' do
    department_manager = create :department_manager
    social_worker = create :social_worker
    user_volunteer = create :user_volunteer

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

  test 'user index has valid links for users without profile' do
    superadmin_no_profile = create :user, :without_profile
    department_manager_no_profile = create :user, :without_profile, :department_manager
    social_worker_no_profile = create :user, :without_profile, :social_worker
    volunteer_no_profile = create :user_volunteer

    visit users_path
    assert page.has_link? superadmin_no_profile.email
    click_link superadmin_no_profile.email
    assert page.has_text? 'Rolle Superadmin'

    visit users_path
    assert page.has_link? department_manager_no_profile.email
    click_link department_manager_no_profile.email
    assert page.has_text? 'Rolle Freiwilligenverantwortliche/r'

    visit users_path
    assert page.has_link? social_worker_no_profile.email
    click_link social_worker_no_profile.email
    assert page.has_text? 'Rolle Sozialarbeiter/in'

    visit users_path
    assert page.has_link? volunteer_no_profile.full_name
    click_link volunteer_no_profile.full_name
    assert page.has_text? volunteer_no_profile.full_name
  end
end
