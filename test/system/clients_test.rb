require 'application_system_test_case'

class ClientsTest < ApplicationSystemTestCase
  setup do
    @user = create :user_with_profile, email: 'superadmin@example.com'
    login_as @user
  end

  test 'new client form' do
    visit new_client_path

    fill_in 'First name', with: 'asdf'
    fill_in 'Last name', with: 'asdf'
    within '.client_date_of_birth' do
      select_date all('select'), '10', 'November', '1995'
    end
    page.choose('client_gender_female')
    select('Aruba', from: 'Nationality')
    page.choose('client_permit_b')
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'
    fill_in 'Email', with: 'gurke@gurkenmail.ch'
    fill_in 'Phone', with: '0123456789'
    click_on('Add language')
    select('Akan', from: 'Language')
    select('Fluent', from: 'Level')
    click_on('Add family member')
    within '#relatives' do
      fill_in 'First name', with: 'asdf'
      fill_in 'Last name', with: 'asdf'
      select_date page.all('select'), '10', 'February', '2001'
    end
    fill_in 'Relation', with: 'Onkel'
    fill_in 'Goals', with: 'asdfasdf'
    fill_in 'Education', with: 'asdfasdf'
    fill_in 'Hobbies', with: 'asdfasdf'
    fill_in 'Interests', with: 'asdfasdf'
    select('Active', from: 'State')
    fill_in 'Comments', with: 'asdfasdf'
    fill_in 'Competent authority', with: 'asdfasdf'
    fill_in 'Involved authority', with: 'asdfasdf'
    page.check('client_schedules_attributes_17_available')

    click_button 'Create Client'
    assert page.has_text? 'Client was successfully created.'
  end

  test 'if required fields are left blank' do
    visit new_client_path
    click_button 'Create Client'
    assert page.has_text? 'Please review the problems below:'
    within '.client_first_name' do
      assert page.has_text? "can't be blank"
    end
    within '.client_last_name' do
      assert page.has_text? "can't be blank"
    end
  end
end
