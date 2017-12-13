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
    assert page.has_link? 'Standorte'
  end

  test 'other users should not see departments link in navigation' do
    login_as @social_worker
    visit root_path
    refute page.has_link? 'Standorte'
  end

  test 'superadmin can see all departments in departments_path' do
    login_as @superadmin
    visit departments_path
    Department.all.sample do |d|
      assert page.has_text? d.contact.last_name
      assert page.has_link? 'Show', href: department_path(d.id)
      assert page.has_link? 'Edit', href: edit_department_path(d.id)
      assert page.has_link? 'Delete', href: department_path(d.id)
    end
  end

  test 'superadmin can create department' do
    assocable_users = User.department_assocable
    login_as @superadmin
    visit departments_path
    click_link 'New Department'
    assocable_users.each do |u|
      check u.to_label
    end
    fill_in 'Name', with: 'Bogus Hog Department'
    fill_in 'Street', with: 'bogus street 999'
    fill_in 'Extended address', with: 'bogus ext. addr.'
    fill_in 'Zip', with: '9999'
    fill_in 'City', with: 'bogus town'
    fill_in 'Primary email', with: 'department@aoz.ch'
    fill_in 'Primary phone', with: '0441234567'
    click_button 'Create Department'
    assert page.has_text? 'Department was successfully created.'
    assert page.has_text? 'Bogus Hog Department'
    assert page.has_text? 'Street'
    assert page.has_text? 'Extended address'
    assert page.has_text? 'City'
    assert page.has_text? 'bogus street 999'
    assert page.has_text? 'bogus ext. addr.'
    assert page.has_text? '9999'
    assert page.has_text? 'bogus town'
    assert page.has_text? 'department@aoz.ch'
    assert page.has_text? '0441234567'
    assocable_users.each do |user|
      assert page.has_link? user.full_name, href: profile_path(user.profile)
    end
    assert page.has_link? 'Edit'
    assert page.has_link? 'Back'
  end

  test 'As Department Manager there is a link in the Navbar to his department' do
    login_as @department_manager
    visit profile_path(@department_manager.profile.id)
    assert page.has_link? 'Department',
      href: department_path(@department_manager.department.first.id)
  end

  test "Department Managers can update their department's fields" do
    login_as @department_manager
    visit edit_department_path(@department_manager.department.first.id)
    refute page.has_select? 'User'
    fill_in 'Name', with: 'Name changed'
    fill_in 'Street', with: 'Street changed'
    fill_in 'Extended address', with: 'Extended address changed'
    fill_in 'Zip', with: 'Zip changed'
    fill_in 'City', with: 'City changed'
    fill_in 'Primary email', with: 'department@aoz.ch'
    fill_in 'Primary phone', with: '0441234567'
    click_button 'Update Department'
    assert page.has_text? 'Name changed'
    assert page.has_text? 'Street changed'
    assert page.has_text? 'Extended address changed'
    assert page.has_text? 'Zip changed'
    assert page.has_text? 'City changed'
    assert page.has_text? 'department@aoz.ch'
    assert page.has_text? '0441234567'
  end

  test 'After logging in as Department Manager he should see his department' do
    visit new_user_session_path
    fill_in 'Email', with: @department_manager.email
    fill_in 'Password', with: 'asdfasdf'
    click_button 'Log in'
    assert page.has_text? @department_manager.department.first.contact.last_name
    if @department_manager.department.first.contact.street.present?
      assert page.has_text? @department_manager.department.first.contact.street
    end
  end

  test 'department has no secondary phone field' do
    login_as @superadmin
    visit new_department_path
    refute page.has_text? 'Secondary phone'

    visit department_path(Department.first)
    refute page.has_text? 'Secondary phone'
  end

  test 'departments group offers with volunteers are displayed' do
    department = @department_manager.department.first
    volunteers = [create(:volunteer), create(:volunteer)]
    group_offer = create :group_offer, volunteers: volunteers, department: department
    login_as @department_manager
    visit department_path(department)
    assert page.has_link? group_offer.title
    volunteers.each do |volunteer|
      assert page.has_link? volunteer.full_name
    end
  end

  test 'department with department manager without profile has valid link on show' do
    department = create :department
    department_manager_no_profile = create :user, :without_profile, :department_manager
    login_as @superadmin
    visit edit_department_path(department)
    page.check(department_manager_no_profile.email.to_s)
    click_button 'Update Department'

    visit department_path(department)
    assert page.has_link? department_manager_no_profile.email
    click_link department_manager_no_profile.email
    assert page.has_text? department_manager_no_profile.email
  end
end
