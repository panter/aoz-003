require 'test_helper'

class ClientPolicyTest < PolicyAssertions::Test
  def setup
    @superadmin = create :user, :with_clients, role: 'superadmin'
    @social_worker = create :user, :with_clients, role: 'social_worker'
    @department_manager = create :department_manager
  end

  test 'Create: superadmin can create' do
    assert_permit @superadmin, Client, 'new?', 'create?'
  end

  test 'Create: department manager can create' do
    assert_permit @department_manager, Client, 'new?', 'create?'
  end

  test 'Destroy: superadmin can destroy' do
    assert_permit @superadmin, Client.first, 'destroy?'
  end

  test 'Destroy: social worker cannot destroy' do
    refute_permit @social_worker, Client.first, 'destroy?'
  end

  test 'Destroy: department manager cannot destroy' do
    refute_permit @department_manager, Client.first, 'destroy?'
  end

  test 'Update: superadmin can update her client' do
    assert_permit @superadmin, @superadmin.clients.first, 'update?', 'edit?'
  end

  test 'Update: superadmin can update others client' do
    assert_permit @superadmin, @social_worker.clients.first, 'update?', 'edit?'
  end

  test 'Update: social worker can update her client' do
    assert_permit @social_worker, @social_worker.clients.first, 'update?', 'edit?'
  end

  test 'Update: social worker cannot update others client' do
    refute_permit @social_worker, @superadmin.clients.first, 'update?', 'edit?'
  end

  test 'Update: department manager cannot update clients' do
    refute_permit @department_manager, Client.first, 'update?', 'edit?'
  end

  test 'Show: department manager can show clients' do
    assert_permit @department_manager, Client.first, 'show?'
  end

  test 'Show: superadmin can see all clients' do
    Client.all.each do |client|
      assert_permit @superadmin, client, 'show?'
    end
  end

  test 'Index: department manager cannot index clients' do
    assert_permit @department_manager, Client.first, 'index?'
  end
end
