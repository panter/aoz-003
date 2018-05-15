require 'test_helper'

class UserPolicyTest < PolicyAssertions::Test
  def setup
    @superadmin = create :user, :with_clients, role: 'superadmin'
    @other_superadmin = create :user, role: 'superadmin'
    @social_worker = create :user, :with_clients, role: 'social_worker'
    @department_manager = create :department_manager
  end

  test 'Destroy: superadmin can delete other user' do
    assert_permit @superadmin, @social_worker, 'destroy?'
    assert_permit @superadmin, @department_manager, 'destroy?'
  end

  test 'Destroy: superadmin can delete other superadmin' do
    assert_permit @superadmin, @other_superadmin, 'destroy?'
  end

  test 'Destroy: superadmin cannot delete itself' do
    refute_permit @superadmin, @superadmin, 'destroy?'
  end

  test 'New: superadmin can create user' do
    assert_permit @superadmin, User, 'new?', 'create?'
  end

  test 'New: social worker cannot create user' do
    refute_permit @social_worker, User, 'create?', 'new?'
  end

  test 'New: department manager cannot create user' do
    refute_permit @department_manager, User, 'create?', 'new?'
  end

  test 'Update: user can update herself' do
    assert_permit @superadmin, @superadmin, 'update?', 'edit?'
    assert_permit @social_worker, @social_worker, 'update?', 'edit?'
    assert_permit @department_manager, @department_manager, 'update?', 'edit?'
  end

  test 'Update: social worker cannot update other user' do
    refute_permit @social_worker, @superadmin, 'update?', 'edit?'
    refute_permit @social_worker, @department_manager, 'update?', 'edit?'
  end

  test 'Update: department manager can notupdate other user' do
    refute_permit @department_manager, @superadmin, 'update?', 'edit?'
    refute_permit @department_manager, @social_worker, 'update?', 'edit?'
  end

  test 'Update: superadmin can update other user' do
    assert_permit @superadmin, @social_worker, 'update?', 'edit?'
    assert_permit @superadmin, @department_manager, 'update?', 'edit?'
    assert_permit @superadmin, @other_superadmin, 'update?', 'edit?'
  end

  test 'Show: superadmin can show users' do
    User.all.each do |user|
      assert_permit @superadmin, user, 'show?'
    end
  end

  test 'Show: department manager cannot show other user' do
    refute_permit @department_manager, @superadmin, 'show?'
  end

  test 'Show: social worker cannot show users' do
    refute_permit @social_worker, @department_manager, 'show?'
  end

  test 'Index: department manager cannot index users' do
    refute_permit @department_manager, @superadmin, 'index?'
    refute_permit @department_manager, @social_worker, 'index?'
    refute_permit @department_manager, @department_manager, 'index?'
  end

  test 'Index: social worker cannot index users' do
    refute_permit @social_worker, @department_manager, 'index?'
    refute_permit @social_worker, @superadmin, 'index?'
  end
end
