require 'test_helper'

class ClientPolicyTest < ActiveSupport::TestCase
  def setup
    @user_as_superadmin = create :user, :with_clients
    @user_as_social_worker = create :user, :with_clients, role: 'social_worker'
    @user_as_department_manager = create :user, role: 'department_manager'
  end

  test 'Create: superadmin can create' do
    assert_permit @user_as_superadmin, Client, 'new?', 'create?'
  end

  test 'Create: social worker can create' do
    assert_permit @user_as_social_worker, Client, 'new?', 'create?'
  end

  test 'Create: department manager cannot create' do
    refute_permit @user_as_department_manager, Client, 'new?', 'create?'
  end

  test 'Destroy: superadmin can destroy' do
    assert_permit @user_as_superadmin, Client.first, 'destroy?'
  end

  test 'Destroy: social worker cannot destroy' do
    refute_permit @user_as_social_worker, Client.first, 'destroy?'
  end

  test 'Destroy: department manager cannot destroy' do
    refute_permit @user_as_department_manager, Client.first, 'destroy?'
  end

  test 'Update: superadmin can update her client' do
    assert_permit @user_as_superadmin, @user_as_superadmin.clients.first, 'update?', 'edit?'
  end

  test 'Update: superadmin can update others client' do
    assert_permit @user_as_superadmin, @user_as_social_worker.clients.first, 'update?', 'edit?'
  end

  test 'Update: social worker can update her client' do
    assert_permit @user_as_social_worker, @user_as_social_worker.clients.first, 'update?', 'edit?'
  end

  test 'Update: social worker cannot update others client' do
    refute_permit @user_as_social_worker, @user_as_superadmin.clients.first, 'update?', 'edit?'
  end

  test 'Update: department manager cannot update clients' do
    refute_permit @user_as_department_manager, Client.first, 'update?', 'edit?'
  end

  test 'Show: social worker cannot show others clients' do
    refute_permit @user_as_social_worker, @user_as_superadmin.clients.first, 'show?'
  end

  test 'Show: department manager cannot show clients' do
    refute_permit @user_as_department_manager, Client.first, 'show?'
  end

  test 'Show: superadmin can see all clients' do
    Client.all.each do |client|
      assert_permit @user_as_superadmin, client, 'show?'
    end
  end

  test 'Index: department manager cannot index clients' do
    refute_permit @user_as_department_manager, Client.first, 'index?'
  end
end
