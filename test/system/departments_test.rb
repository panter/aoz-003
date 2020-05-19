require 'application_system_test_case'

class DepartmentsTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user, :with_clients,
                         :with_department, role: 'superadmin'
    @social_worker = create :user, :with_clients,
                            :with_department, role: 'social_worker'
    @department_manager = create :department_manager
    # dirty fix for not properly working factorys or DatabaseCleaner
    User.where.not(id: [@superadmin.id, @social_worker.id, @department_manager.id]).destroy_all
  end

  test 'superadmin should see departments link in navigation' do
    login_as @superadmin
    visit root_path
    assert_link 'Standorte'
  end

  test 'other users should not see departments link in navigation' do
    login_as @social_worker
    visit root_path
    assert_text 'Klient/innen'
    refute_link 'Standorte', wait: 0
  end

  test 'superadmin can see all departments in departments_path' do
    login_as @superadmin
    visit departments_path
    Department.all.sample do |department|
      assert_text d.contact.last_name
      assert_link 'Anzeigen', href: department_path(department.id)
      assert_link 'Bearbeiten', href: edit_department_path(department.id)
      assert_link 'Löschen', href: department_path(department.id)
    end
  end

  test 'superadmin can create department' do
    assocable_users = User.department_assocable
    login_as @superadmin
    visit departments_path
    first(:link, 'Standort erfassen').click
    assocable_users.each do |user|
      check user.to_s
    end
    fill_in 'Name', with: 'Bogus Hog Department'
    fill_in 'Strasse', with: 'bogus street 999'
    fill_in 'Adresszusatz', with: 'bogus ext. addr.'
    fill_in 'PLZ', with: '9999'
    fill_in 'Ort', with: 'bogus town'
    fill_in 'Mailadresse', with: 'department@aoz.ch'
    fill_in 'Telefonnummer', with: '0441234567'
    click_button 'Standort erfassen'
    assert_text 'Standort wurde erfolgreich erstellt.'
    assert_text 'Bogus Hog Department'
    assert_text 'Strasse'
    assert_text 'Adresszusatz'
    assert_text 'Ort'
    assert_text 'bogus street 999'
    assert_text 'bogus ext. addr.'
    assert_text '9999'
    assert_text 'bogus town'
    assert_text 'department@aoz.ch'
    assert_text '0441234567'
    assocable_users.each do |user|
      assert_link user.full_name, href: /profiles\/#{user.profile.id}/
    end
    assert_link 'Standort bearbeiten'
    assert_link 'Zurück'
  end

  test 'As Department Manager there is a link in the Navbar to his department' do
    login_as @department_manager
    visit profile_path(@department_manager.profile.id)
    assert_link 'Standort',
                href: department_path(@department_manager.department.first.id)
  end

  test "Department Managers can update their department's fields" do
    login_as @department_manager
    visit edit_department_path(@department_manager.department.first.id)
    fill_in 'Name', with: 'Name changed'
    fill_in 'Strasse', with: 'Street changed'
    fill_in 'Adresszusatz', with: 'Extended address changed'
    fill_in 'PLZ', with: 'Zip changed'
    fill_in 'Ort', with: 'City changed'
    fill_in 'Mailadresse', with: 'department@aoz.ch'
    fill_in 'Telefonnummer', with: '0441234567'
    refute page.has_select? 'User', wait: 0
    click_button 'Standort aktualisieren'
    assert_text 'Name changed'
    assert_text 'Street changed'
    assert_text 'Extended address changed'
    assert_text 'Zip changed'
    assert_text 'City changed'
    assert_text 'department@aoz.ch'
    assert_text '0441234567'
  end

  test 'After logging in as Department Manager he should see his department' do
    visit new_user_session_path
    fill_in 'Email', with: @department_manager.email
    fill_in 'Passwort', with: 'asdfasdf'
    click_button 'Anmelden'
    assert_text @department_manager.department.first.contact.last_name
    if @department_manager.department.first.contact.street.present?
      assert_text @department_manager.department.first.contact.street
    end
  end

  test 'department has no secondary phone field' do
    login_as @superadmin
    visit new_department_path
    assert_text 'Standort erfassen'
    refute_text 'Secondary phone', wait: 0

    visit department_path(Department.first)
    assert_text Department.first
    refute_text 'Secondary phone', wait: 0
  end

  test 'departments group offers with volunteers are displayed' do
    department = @department_manager.department.first
    volunteer_one = create(:volunteer)
    volunteer_two = create(:volunteer)
    group_offer = create :group_offer, department: department
    create :group_assignment, group_offer: group_offer, volunteer: volunteer_one
    create :group_assignment, group_offer: group_offer, volunteer: volunteer_two

    login_as @department_manager
    visit department_path(department)
    assert_link group_offer.title
    assert_text volunteer_one.full_name
    assert_text volunteer_two.full_name
  end

  test 'department with department manager without profile has valid link on show' do
    department = create :department
    department_manager_no_profile = create :user, :without_profile, :department_manager
    login_as @superadmin
    visit edit_department_path(department)
    page.check(department_manager_no_profile.email.to_s)
    click_button 'Standort aktualisieren'

    visit department_path(department)
    assert_link department_manager_no_profile.email
    click_link department_manager_no_profile.email
    assert_field 'Email', with: department_manager_no_profile.email
  end
end
