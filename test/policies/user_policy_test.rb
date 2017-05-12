require 'test_helper'

class UserPolicyTest < ActiveSupport::TestCase
  def setup
    @user_as_superadmin = create :user, :with_clients, :with_profile
    @user_as_other_superadmin = create :user, :with_profile
    @user_as_social_worker = create :user, :with_clients, :with_profile, role: 'social_worker'
    @user_as_department_manager = create :user, :with_profile, role: 'department_manager'
  end

  test 'Destroy: superadmin can delete other user' do
    assert_permit @user_as_superadmin, @user_as_social_worker, 'destroy?'
    assert_permit @user_as_superadmin, @user_as_department_manager, 'destroy?'
  end

  test 'Destroy: superadmin cannot delete other superadmin' do
    refute_permit @user_as_superadmin, @user_as_other_superadmin, 'destroy?'
  end

  test 'Destroy: superadmin cannot delete itself' do
    refute_permit @user_as_superadmin, @user_as_superadmin, 'destroy?'
  end

  test 'New: superadmin can create user' do
    assert_permit @user_as_superadmin, User, 'new?', 'create?'
  end

  test 'New: social worker cannot create user' do
    refute_permit @user_as_social_worker, User, 'create?', 'new?'
  end

  test 'New: department manager cannot create user' do
    refute_permit @user_as_department_manager, User, 'create?', 'new?'
  end

  test 'Update: user can update herself' do
    assert_permit @user_as_superadmin, @user_as_superadmin, 'update?', 'edit?'
    assert_permit @user_as_social_worker, @user_as_social_worker, 'update?', 'edit?'
    assert_permit @user_as_department_manager, @user_as_department_manager, 'update?', 'edit?'
  end

  test 'Update: social worker cannot update other user' do
    refute_permit @user_as_social_worker, @user_as_superadmin, 'update?', 'edit?'
    refute_permit @user_as_social_worker, @user_as_department_manager, 'update?', 'edit?'
  end

  test 'Update: department manager can notupdate other user' do
    refute_permit @user_as_department_manager, @user_as_superadmin, 'update?', 'edit?'
    refute_permit @user_as_department_manager, @user_as_social_worker, 'update?', 'edit?'
  end

  test 'Update: superadmin can update other user' do
    assert_permit @user_as_superadmin, @user_as_social_worker, 'update?', 'edit?'
    assert_permit @user_as_superadmin, @user_as_department_manager, 'update?', 'edit?'
    assert_permit @user_as_superadmin, @user_as_other_superadmin, 'update?', 'edit?'
  end

  test 'Show: superadmin can show users' do
    User.all.each do |user|
      assert_permit @user_as_superadmin, user, 'show?'
    end
  end

  test 'Show: department manager cannot show other user' do
    refute_permit @user_as_department_manager, @user_as_superadmin, 'show?'
  end

  test 'Show: social worker cannot show users' do
    refute_permit @user_as_social_worker, @user_as_department_manager, 'show?'
  end

  test 'Index: department manager cannot index users' do
    refute_permit @user_as_department_manager, @user_as_superadmin, 'index?'
    refute_permit @user_as_department_manager, @user_as_social_worker, 'index?'
    refute_permit @user_as_department_manager, @user_as_department_manager, 'index?'
  end

  test 'Index: social worker cannot index users' do
    refute_permit @user_as_social_worker, @user_as_department_manager, 'index?'
    refute_permit @user_as_social_worker, @user_as_superadmin, 'index?'
  end
end
