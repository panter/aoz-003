require 'test_helper'

class ClientPolicyTest < PolicyAssertions::Test
  def setup
    @superadmin = create :user, :with_clients, role: 'superadmin'
    @social_worker = create :user, :with_clients, role: 'social_worker'
    @department_manager = create :user, role: 'department_manager'
  end

  test 'Create: superadmin can create' do
    assert_permit @superadmin, Client, 'new?', 'create?'
  end

  test 'Create: social worker can create' do
    assert_permit @social_worker, Client, 'new?', 'create?'
  end

  test 'Create: department manager cannot create' do
    refute_permit @department_manager, Client, 'new?', 'create?'
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

  test 'Show: social worker cannot show others clients' do
    refute_permit @social_worker, @superadmin.clients.first, 'show?'
  end

  test 'Show: department manager cannot show clients' do
    refute_permit @department_manager, Client.first, 'show?'
  end

  test 'Show: superadmin can see all clients' do
    Client.all.each do |client|
      assert_permit @superadmin, client, 'show?'
    end
  end

  test 'Index: department manager cannot index clients' do
    refute_permit @department_manager, Client.first, 'index?'
  end

  test 'Without assignments: superadmin can see clients without_assignments' do
    assert_permit @superadmin, Client.first, 'without_assignments?'
  end

  test 'Without assignments: social worker cannot see clients without assignments' do
    refute_permit @social_worker, Client.first, 'without_assignments?'
  end

  test 'Without assignments: department manager cannot see clients without assignments' do
    refute_permit @department_manager, Client.first, 'without_assignments?'
  end
end
