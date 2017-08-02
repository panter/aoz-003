require 'application_system_test_case'

class ClientsTest < ApplicationSystemTestCase
  setup do
    @user = create :user, email: 'superadmin@example.com'
    login_as @user
  end

  test 'new client form' do
    visit new_client_path

    fill_in 'First name', with: 'asdf'
    fill_in 'Last name', with: 'asdf'
    within '.client_birth_year' do
      select('1995', from: 'Birth year')
    end
    select('Mrs.', from: 'Salutation')
    select('Aruba', from: 'Nationality')
    page.choose('client_permit_b')
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'

    fill_in 'Primary email', with: 'gurke@gurkenmail.com'
    fill_in 'Primary phone', with: '0123456789'

    click_link 'Add Phone number'
    fill_in 'Phone number', with: '0123456789'

    click_on('Add language')
    select('Akan', from: 'Language')
    select('Fluent', from: 'Level')
    click_on('Add family member')
    within '#relatives' do
      fill_in 'First name', with: 'asdf'
      fill_in 'Last name', with: 'asdf'
      select('2001', from: 'Birth year')
      select('Uncle', from: 'Relation')
    end
    fill_in 'Goals', with: 'asdfasdf'
    select('gender same', from: "Volunteer's gender")
    select('36 - 50', from: "Volunteer's age")
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

  test 'new client form with preselected fields' do
    visit new_client_path
    select('Mrs.', from: 'Salutation')
    fill_in 'First name', with: 'Client'
    fill_in 'Last name', with: "doesn't matter"
    fill_in 'Primary email', with: 'client@aoz.com'
    fill_in 'Primary phone', with: '0123456789'
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'
    click_button 'Create Client'
    assert page.has_text? 'Client was successfully created.'
    within '.table-no-border-top' do
      assert page.has_text? "age doesn't matter"
      assert page.has_text? "gender doesn't matter"
    end
  end

  test 'new client can select custom language' do
    visit new_client_path
    select('Mrs.', from: 'Salutation')
    fill_in 'First name', with: 'Dari'
    fill_in 'Last name', with: 'Dari'
    fill_in 'Primary email', with: 'client@aoz.com'
    fill_in 'Primary phone', with: '0123456789'
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'

    click_on('Add language')
    select('Dari', from: 'Language')
    select('Native speaker', from: 'Level')

    click_button 'Create Client'
    assert page.has_text? 'Client was successfully created.'
    within '.table-no-border-top' do
      assert page.has_text? 'Dari Native speaker'
    end
  end

  test 'language without a level shows only language' do
    visit new_client_path
    select('Mrs.', from: 'Salutation')
    fill_in 'First name', with: 'asdf'
    fill_in 'Last name', with: 'asdf'
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'
    fill_in 'Primary email', with: 'gurke@gurkenmail.com'
    fill_in 'Primary phone', with: '0123456789'

    click_on('Add language')
    select('Farsi', from: 'Language')

    click_button 'Create Client'
    within '.table-no-border-top' do
      refute page.has_text? ':native_speaker=>"Native speaker"'
    end

    visit clients_path
    assert page.has_text? 'Farsi'
  end

  test 'level without a language is not shown' do
    visit new_client_path
    select('Mrs.', from: 'Salutation')
    fill_in 'First name', with: 'asdf'
    fill_in 'Last name', with: 'asdf'
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'
    fill_in 'Primary email', with: 'gurke@gurkenmail.com'
    fill_in 'Primary phone', with: '0123456789'

    click_on('Add language')
    select('Fluent', from: 'Level')

    click_button 'Create Client'
    within '.table-no-border-top' do
      refute page.has_text? 'Fluent'
    end

    visit clients_path
    refute page.has_text? 'Fluent'
  end

  test 'superadmin can delete client' do
    create :client
    visit clients_path
    click_link 'Delete'

    assert page.has_text? 'Client was successfully deleted.'
  end

  test 'client pagination' do
    70.times do
      create :client
    end
    visit clients_path
    first(:link, '2').click

    assert page.has_css? 'div.pagination'
    Client.all.paginate(page: 2).each do |client|
      assert page.has_text? client.contact.last_name
    end
  end
end
