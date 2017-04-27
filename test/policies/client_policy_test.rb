require 'test_helper'

class ClientPolicyTest < ActiveSupport::TestCase
  def setup
    @user_superadmin = create :user, :with_clients
    @user_social_worker = create :user, :with_clients, role: 'social_worker'
  end

  test 'Create: superadmin can create' do
    assert_permit @user_superadmin, Client, 'new?', 'create?'
  end

  test 'Create: social_worker can create' do
    assert_permit @user_social_worker, Client, 'new?', 'create?'
  end

  test 'Destroy: superadmin can destroy' do
    assert_permit @user_superadmin, Client.first, 'destroy?'
  end

  test 'Destroy: social_worker can not destroy' do
    refute_permit @user_social_worker, Client.first, 'destroy?'
  end

  test 'Update: superadmin can update her client' do
    assert_permit @user_superadmin, @user_superadmin.clients.first, 'update?', 'edit?'
  end

  test 'Update: superadmin can update others client' do
    assert_permit @user_superadmin, @user_social_worker.clients.first, 'update?', 'edit?'
  end

  test 'Update: social_worker can update her client' do
    assert_permit @user_social_worker, @user_social_worker.clients.first, 'update?', 'edit?'
  end

  test 'Update: social_worker can not update others client' do
    refute_permit @user_social_worker, @user_superadmin.clients.first, 'update?', 'edit?'
  end

  test 'Show: social_worker can not see others clients' do
    refute_permit @user_social_worker, @user_superadmin.clients.first, 'show?'
  end

  test 'Show: superadmin can see all clients' do
    Client.all.each do |client|
      assert_permit @user_superadmin, client, 'show?'
    end
  end
end
