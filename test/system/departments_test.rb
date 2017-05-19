require 'application_system_test_case'

class DepartmentsTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user, :with_profile, :with_clients,
      :with_departments, role: 'superadmin'
    @social_worker = create :user, :with_profile, :with_clients,
      :with_departments, role: 'social_worker'
    @department_manager = create :user, :with_profile, :with_departments,
      role: 'department_manager'
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
      assert page.has_text? d.contact.name
      assert page.has_link? 'Show', href: department_path(d.id)
      assert page.has_link? 'Edit', href: edit_department_path(d.id)
      assert page.has_link? 'Delete', href: department_path(d.id)
    end
  end

  test 'superadmin can create department' do
    login_as @superadmin
    visit departments_path
    click_link 'New Department'
    assert page.has_select? 'User'
    within '.department_user' do
      User.department_assocable.each do |u|
        select u.email
      end
    end
    fill_in 'Name', with: 'Bogus Hog Department'
    fill_in 'Street', with: 'bogus street 999'
    fill_in 'Extended address', with: 'bogus ext. addr.'
    fill_in 'Zip', with: '9999'
    fill_in 'City', with: 'bogus town'
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
    User.department_assocable.each do |user|
      assert page.has_text? user.email
    end
    assert page.has_link? 'Edit'
    assert page.has_link? 'Back'
  end

  test 'superadmin can update a department with additional email and fax number' do
    login_as @superadmin
    visit departments_path
    click_link 'Edit', href: edit_department_path(Department.first.id)
    within '#emails' do
      within '.links' do
        click_link 'Add Email address'
      end
      within find_all('.nested-fields').last do
        fill_in 'Email address', with: 'hocusbocus@nowhere.com'
      end
    end
    click_button 'Update Department'
    assert page.has_link? 'hocusbocus@nowhere.com'
    click_link 'Edit'

    within '#phones' do
      within '.links' do
        click_link 'Add Phone number'
      end
      within find_all('.nested-fields').last do
        assert page.has_field? 'Phone number'
        fill_in 'Phone number', with: '88888 88 88 88'
      end
    end
    click_button 'Update Department'
    assert page.has_text? '88888 88 88 88'
  end

  test 'superadmin can remove phone and email from department' do
    department = Department.first
    delete_email = department.contact.contact_emails.last.body
    delete_phone = department.contact.contact_phones.last.body
    login_as @superadmin
    visit departments_path
    click_link 'Show', href: department_path(department.id)
    assert page.has_link? delete_email
    assert page.has_text? delete_phone
    click_link 'Edit'
    within '#emails' do
      within find_all('.nested-fields').last do
        assert page.has_field? 'Email address', with: delete_email
        click_link 'Delete Email address'
      end
    end
    click_button 'Update Department'
    refute page.has_link? delete_email
    click_link 'Edit'
    within '#phones' do
      within find_all('.nested-fields').last do
        assert page.has_field? 'Phone number', with: delete_phone
        click_link 'Delete Phone number'
      end
    end
    click_button 'Update Department'
    refute page.has_text? delete_phone
  end

  test 'As Department Manager there is a link in the Navbar to his department' do
    login_as @department_manager
    visit profile_path(@department_manager.profile.id)
    assert page.has_link? @department_manager.department.first.contact.name
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
    within '#phones' do
    end
    within '#emails' do
      within find_all('.nested-fields').first do
        fill_in 'Email address', with: 'changed@email.com'
      end
    end
    within '#phones' do
      within find_all('.nested-fields').first do
        fill_in 'Phone number', with: '++888 88 88 9999 888'
      end
    end
    click_button 'Update Department'
    assert page.has_text? 'Name changed'
    assert page.has_text? 'Street changed'
    assert page.has_text? 'Extended address changed'
    assert page.has_text? 'Zip changed'
    assert page.has_text? 'City changed'
    assert page.has_link? 'changed@email.com'
    assert page.has_text? '++888 88 88 9999 888'
  end

  test 'After logging in as Department Manager he should see his department' do
    login_as @department_manager
    visit root_path
    her_department = @department_manager.department.first
    assert page.has_text? her_department.contact.name
    if her_department.contact.street.present?
      assert page.has_text? her_department.contact.street
    end
  end
end
