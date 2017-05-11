require 'test_helper'

class ProfilePolicyTest < ActiveSupport::TestCase
  def setup
    @user_as_superadmin = create :user, :with_clients, :with_profile
    @user_as_social_worker = create :user, :with_clients, :with_profile, role: 'social_worker'
    @user_as_department_manager = create :user, :with_profile, role: 'department_manager'
    @user_without_profile = create :user
  end

  test 'New: user can create his profile' do
    profile_params = {
      user: @user_without_profile,
      first_name: 'fn',
      last_name: 'ln'
    }
    assert_permit @user_without_profile, Profile.new(profile_params), 'create?', 'new?'
  end

  test 'Update: user can update own profile' do
    assert_permit @user_as_social_worker, @user_as_social_worker.profile, 'update?', 'edit?'
    assert_permit @user_as_department_manager, @user_as_department_manager.profile, 'update?'
    assert_permit @user_as_department_manager, @user_as_department_manager.profile, 'edit?'
    assert_permit @user_as_superadmin, @user_as_superadmin.profile, 'update?', 'edit?'
  end

  test 'Update: simple user cannot update others profile' do
    refute_permit @user_as_social_worker, @user_as_superadmin.profile, 'update?', 'edit?'
    refute_permit @user_as_department_manager, @user_as_superadmin.profile, 'update?', 'edit?'
  end

  test 'Update: superadmin can update others profile' do
    assert_permit @user_as_superadmin, @user_as_social_worker.profile, 'update?', 'edit?'
    assert_permit @user_as_superadmin, @user_as_department_manager.profile, 'update?', 'edit?'
  end

  test 'Destroy: profiles can not be destroyed' do
    refute_permit @user_as_superadmin, @user_as_superadmin.profile, 'destroy?'
    refute_permit @user_as_superadmin, @user_as_social_worker.profile, 'destroy?'
    refute_permit @user_as_superadmin, @user_as_department_manager.profile, 'destroy?'
  end

  test 'Show: social_worker can only show her own profile' do
    refute_permit @user_as_social_worker, @user_as_superadmin.profile, 'show?'
  end

  test 'Show: department manager can only her own profile' do
    refute_permit @user_as_department_manager, @user_as_superadmin.profile, 'show?'
  end

  test 'Show: superadmin can show all profiles' do
    Profile.all.each do |profile|
      assert_permit @user_as_superadmin, profile, 'show?'
    end
  end
end
