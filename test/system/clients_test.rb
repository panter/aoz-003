require 'application_system_test_case'

class ClientsTest < ApplicationSystemTestCase
  setup do
    @user = create :user, :with_profile, email: 'superadmin@example.com'
    login_as @user
  end

  test 'new client form' do
    visit new_client_path

    fill_in 'First name', with: 'asdf'
    fill_in 'Last name', with: 'asdf'
    within '.client_date_of_birth' do
      select('1995', from: 'Date of birth')
    end
    page.choose('client_gender_female')
    select('Aruba', from: 'Nationality')
    page.choose('client_permit_b')
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'

    click_link 'Add Email address'
    fill_in 'Email address', with: 'gurke@gurkenmail.com'

    click_link 'Add Phone number'
    fill_in 'Phone number', with: '0123456789'

    click_on('Add language')
    select('Akan', from: 'Language')
    select('Fluent', from: 'Level')
    click_on('Add family member')
    within '#relatives' do
      fill_in 'First name', with: 'asdf'
      fill_in 'Last name', with: 'asdf'
      select('2001', from: 'Date of birth')
      select('Uncle', from: 'Relation')
    end
    fill_in 'Goals', with: 'asdfasdf'
    page.choose('client_gender_request_same')
    page.choose('client_age_request_age_middle')
    fill_in 'Other request', with: 'asdfasdf'
    fill_in 'Education', with: 'asdfasdf'
    fill_in 'Actual activities', with: 'asdfasdf'
    fill_in 'Interests', with: 'asdfasdf'
    select('Active', from: 'State')
    fill_in 'Comments', with: 'asdfasdf'
    fill_in 'Competent authority', with: 'asdfasdf'
    fill_in 'Involved authority', with: 'asdfasdf'
    page.check('client_schedules_attributes_17_available')

    click_button 'Create Client'
    assert page.has_text? 'Client was successfully created.'
  end

  test 'superadmin can delete client' do
    create :client
    visit clients_path
    click_link 'Delete'

    assert page.has_text? 'Client was successfully deleted.'
  end
end
