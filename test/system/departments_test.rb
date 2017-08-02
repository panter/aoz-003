require 'application_system_test_case'

class DepartmentsTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user, :with_clients,
      :with_departments, role: 'superadmin'
    @social_worker = create :user, :with_clients,
      :with_departments, role: 'social_worker'
    @department_manager = create :user, :with_departments,
      role: 'department_manager'
    # dirty fix for not properly working factorys or DatabaseCleaner
    User.where.not(id: [@superadmin.id, @social_worker.id, @department_manager.id]).destroy_all
  end

  test 'superadmin should see departments link in navigation' do
    login_as @superadmin
    visit root_path
    assert page.has_link? 'Departments'
  end

  test 'other users should not see departments link in navigation' do
    login_as @social_worker
    visit root_path
    refute page.has_link? 'Departments'
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
      assert page.has_link? user.to_label
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
end
