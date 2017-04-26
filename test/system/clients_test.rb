require "application_system_test_case"

class ClientsTest < ApplicationSystemTestCase
  setup do
    @user = create :user_with_profile, email: 'superadmin@example.com'
    login_as @user
  end

  test 'new client form' do
    visit new_client_path

    fill_in 'Firstname', with: 'asdf'
    fill_in 'Lastname', with: 'asdf'
    select('1', :from => 'client_dob_3i')
    select('January', :from => 'client_dob_2i')
    select('2000', :from => 'client_dob_1i')
    page.choose('client_gender_f')
    select('Aruba', :from => 'Nationality')
    page.choose('client_permit_b')
    fill_in 'Street and house number', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'
    fill_in 'Email', with: 'gurke@gurkenmail.ch'
    fill_in 'Phone', with: '0123456789'
    click_on('Add language')
    select('Akan', :from => 'Language')
    select('fluent', :from => 'Level')
    click_on('Add family member')
    fill_in 'Firstname', with: 'asdf'
    fill_in 'Lastname', with: 'asdf'
    select('2', :from => 'client_dob_3i')
    select('February', :from => 'client_dob_2i')
    select('2001', :from => 'client_dob_1i')
    fill_in 'Relation', with: 'Onkel'
    fill_in 'Goals', with: 'asdfasdf'
    fill_in 'Education', with: 'asdfasdf'
    fill_in 'Hobbies', with: 'asdfasdf'
    fill_in 'Interests', with: 'asdfasdf'
    select('active', :from => 'State')
    fill_in 'Comments', with: 'asdfasdf'
    fill_in 'Competent authority', with: 'asdfasdf'
    fill_in 'Involved authorities', with: 'asdfasdf'
    page.check('client_schedules_attributes_17_available')

    click_button 'Create Client'
    assert page.has_text? 'Client was successfully created.'
  end
end
