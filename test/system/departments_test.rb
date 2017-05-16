require 'application_system_test_case'

class DepartmentsTest < ApplicationSystemTestCase
  def setup
    @user = create :user, :with_profile, :with_clients,
      :with_departments, role: 'superadmin'
    @user_as_social_worker = create :user, :with_profile, :with_clients,
      :with_departments, role: 'social_worker'
  end

  test 'superadmin should see departmens link in navigation' do
    login_as @user
    visit root_path
    assert page.has_link? 'Departments'
  end

  test 'other users should not see departmens link in navigation' do
    login_as @user_as_social_worker
    visit root_path
    refute page.has_link? 'Departments'
  end

  test 'superadmin can see all departments in departmens_path' do
    login_as @user
    visit departments_path
    Department.all.each do |d|
      assert page.has_text? d.contact.org_role
      assert page.has_link? 'Show', href: department_path(d.id)
      assert page.has_link? 'Edit', href: edit_department_path(d.id)
      assert page.has_link? 'Delete', href: department_path(d.id)
    end
  end

  test 'superadmin can create department' do
    login_as @user
    visit departments_path
    click_link 'New department'

    assert page.has_select? 'User'
    within '.department_user' do
      User.department_assocable.each do |u|
        select u.email
      end
    end

    fill_in 'Department name', with: 'Bogus Hog Department'
    fill_in 'Street', with: 'bogus street 999'
    fill_in 'Extended address', with: 'bogus ext. addr.'
    fill_in 'Postal code', with: '9999'
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

    assert page.has_link? 'Edit department'
    assert page.has_link? 'Department index'
  end

  test 'superadmin can update a department with additional email and fax number' do
    login_as @user
    visit departments_path
    click_link 'Edit', href: edit_department_path(Department.first.id)
    within '#emails' do
      within '.links' do
        click_link 'New email address'
      end
      within find_all('.nested-email-fields').last do
        fill_in 'Email address', with: 'hocusbocus@nowhere.com'
      end
    end
    click_button 'Update Department'
    assert page.has_link? 'hocusbocus@nowhere.com'
    click_link 'Edit department'

    within '#phones' do
      within '.links' do
        click_link 'New phone number'
      end
      within find_all('.nested-phone-fields').last do
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
    login_as @user
    visit departments_path
    click_link 'Show', href: department_path(department.id)
    assert page.has_link? delete_email
    assert page.has_text? delete_phone
    click_link 'Edit department'
    within '#emails' do
      within find_all('.nested-email-fields').last do
        assert page.has_field? 'Email address', with: delete_email
        click_link 'Delete email address'
      end
    end
    click_button 'Update Department'
    refute page.has_link? delete_email
    click_link 'Edit department'
    within '#phones' do
      within find_all('.nested-phone-fields').last do
        assert page.has_field? 'Phone number', with: delete_phone
        click_link 'Delete phone number'
      end
    end
    click_button 'Update Department'
    refute page.has_text? delete_phone
  end
end
