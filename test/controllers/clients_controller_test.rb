require 'test_helper'

class CliensControllerTest < ActionDispatch::IntegrationTest
  setup do
    @superadmin = create :user, :with_clients
    @department_manager = create :department_manager
    @social_worker = create :social_worker
  end

  test 'superadmin, department_manager, social_worker can destroy inactive clients' do
    [@superadmin, @department_manager, @social_worker].each do |user|
      client = create :client
      login_as user

      assert_difference 'Client.count', -1 do
        delete client_path client
      end
      assert_redirected_to clients_path
    end
  end

  test 'no user can destroy clients with assignment associated' do
    [@superadmin, @department_manager, @social_worker].each do |user|
      login_as user
      client = create :client
      assignment = create :assignment, client: client

      assert_no_difference 'Client.count' do
        delete client_path client
      end
      assert_redirected_to root_path
      assert_nil client.deleted_at
    end
  end

  test 'no user can destroy clients with assignment associated even when its deleted' do
    [@superadmin, @department_manager, @social_worker].each do |user|
      login_as user
      client = create :client
      assignment = create :assignment, client: client
      assignment.destroy

      assert_no_difference 'Client.count' do
        delete client_path client
      end
      assert_redirected_to root_path
      assert_nil client.deleted_at
    end
  end
end
