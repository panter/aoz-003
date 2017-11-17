require 'application_system_test_case'

class ClientNotificationsTest < ApplicationSystemTestCase
  def setup
    @user = create :user
    @social_worker = create :social_worker
    @other_client_notification = create :client_notification, user: @user
    @client_notification = create :client_notification, active: true, user: @user
  end

  test 'the right client notification should be marked active' do
    login_as @user
    visit clients_path
    click_link 'Wartezeit Benachrichtigungen'
    click_link 'Klienten Wartezeit Benachrichtigung erfassen'
    assert page.has_text? @client_notification.body
    within 'tr.bg-success' do
      assert page.has_text? @client_notification.body
      assert page.has_selector?('table > tbody td:nth-child(1) i.glyphicon-ok')
      refute page.has_text? @other_client_notification.body
      refute page.has_selector?('table > tbody td:nth-child(2) i.glyphicon-remove')
    end
  end

  test 'changing another notification to active deactivates the former active' do
    login_as @user
    visit client_notifications_path
    within 'tbody tr:last-child' do
      assert page.has_text? @other_client_notification.body
      click_link 'Edit'
    end
    page.check('client_notification_active')
    click_button 'Update Klienten Wartezeit Benachrichtigung'
    click_link 'Back'
    within 'tr.bg-success' do
      refute page.has_text? @client_notification.body
      assert page.has_text? @other_client_notification.body
    end
  end

  test 'social worker sees notification if a client is registered' do
    login_as @social_worker
    visit clients_path

    click_link 'New Client'
    select('Mrs.', from: 'Salutation')
    fill_in 'First name', with: 'asdf'
    fill_in 'Last name', with: 'asdf'
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'
    fill_in 'Primary email', with: 'gurke@gurkenmail.com'
    fill_in 'Primary phone', with: '0123456789'
    within '#languages' do
      choose('Basic')
    end
    click_button 'Create Client'
    assert page.has_text? @client_notification.body
  end

  test 'social worker does not see notification button on clients index' do
    login_as @social_worker
    visit clients_path

    refute page.has_link? 'Wartezeit Benachrichtigungen'
  end

  test 'superadmin does not see this notification' do
    login_as @user
    visit clients_path

    click_button 'New Client'
    select('Mrs.', from: 'Salutation')
    fill_in 'First name', with: 'asdf'
    fill_in 'Last name', with: 'asdf'
    fill_in 'Street', with: 'Sihlstrasse 131'
    fill_in 'Zip', with: '8002'
    fill_in 'City', with: 'Zürich'
    fill_in 'Primary email', with: 'gurke@gurkenmail.com'
    fill_in 'Primary phone', with: '0123456789'
    within '#languages' do
      choose('Basic')
    end
    click_button 'Create Client'
    assert page.has_text? 'Client was successfully created.'
    refute page.has_text? @client_notification.body
  end
end
