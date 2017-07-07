require 'application_system_test_case'

class VersionsTest < ApplicationSystemTestCase
  setup do
    @user = create :user, email: 'superadmin@example.com'
    @client = create :user
    login_as @user
  end

  test 'client has a history when created' do
    visit new_client_path
    fill_in 'First name', with: 'asdf'
    fill_in 'Last name', with: 'asdf'
    click_button 'Create Client'

    assert page.has_text? 'Client was successfully created.'
    assert page.has_text? 'History'
    assert page.has_text? 'Timepoint'
    assert page.has_text? 'Changed by'
    assert page.has_text? 'Event'
    assert page.has_text? @client.versions.created_at
    assert_equal @client.versions.author, 'superadmin@example.com'
    assert_equal @client.versions.event, 'Create'
  end

  test 'client has a update history when updated' do
    visit client_path(@client)
    fill_in 'Actual activities', with: 'asdfasdf'
    click_button 'Update Client'

    assert page.has_text? 'Client was successfully updated.'
    assert_equal @client.versions.event, 'Update'
  end
end
