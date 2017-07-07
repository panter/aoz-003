require 'application_system_test_case'

class VersionsTest < ApplicationSystemTestCase
  setup do
    with_versioning do
    @user = create :user, email: 'superadmin@example.com'
    @client = create :user, id: 20
    @client.reload
    login_as @user
    end
  end


  test 'client has a history when created' do
    with_versioning do
      visit new_client_path
      fill_in 'First name', with: 'asdf'
      fill_in 'Last name', with: 'asdf'
      click_button 'Create Client'

      assert page.has_text? 'Client was successfully created.'
      assert page.has_text? 'History'
      assert page.has_text? 'Timepoint'
      assert page.has_text? 'Changed by'
      assert page.has_text? 'Event'
      assert page.has_text? 'Create'
    end
  end

  test 'client has a update history when updated' do
    with_versioning do
      visit new_client_path
      fill_in 'First name', with: 'asdf'
      fill_in 'Last name', with: 'asdf'
      click_button 'Create Client'

      click_link 'Edit Client'
      fill_in 'Actual activities', with: 'asdfasdf'
      click_button 'Update Client'

      assert page.has_text? 'Client was successfully updated.'
      assert page.has_text? 'Update'
    end
  end
end
