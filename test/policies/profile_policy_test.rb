require 'test_helper'

class ProfilePolicyTest < PolicyAssertions::Test
  def setup
    @superadmin = create :user, :with_clients, role: 'superadmin'
    @social_worker = create :user, :with_clients, role: 'social_worker'
    @department_manager = create :department_manager
    @user_without_profile = create :user
  end

  test 'New: user can create his profile' do
    profile_params = {
      contact_attributes: {
        first_name: 'fn',
        last_name: 'ln'
      },
      user: @user_without_profile
    }
    assert_permit @user_without_profile, Profile.new(profile_params), 'create?', 'new?'
  end

  test 'Update: user can update own profile' do
    assert_permit @social_worker, @social_worker.profile, 'update?', 'edit?'
    assert_permit @department_manager, @department_manager.profile, 'update?'
    assert_permit @department_manager, @department_manager.profile, 'edit?'
    assert_permit @superadmin, @superadmin.profile, 'update?', 'edit?'
  end

  test 'Update: simple user cannot update others profile' do
    refute_permit @social_worker, @superadmin.profile, 'update?', 'edit?'
    refute_permit @department_manager, @superadmin.profile, 'update?', 'edit?'
  end

  test 'Update: superadmin can update others profile' do
    assert_permit @superadmin, @social_worker.profile, 'update?', 'edit?'
    assert_permit @superadmin, @department_manager.profile, 'update?', 'edit?'
  end

  test 'Destroy: profiles can not be destroyed' do
    refute_permit @superadmin, @superadmin.profile, 'destroy?'
    refute_permit @superadmin, @social_worker.profile, 'destroy?'
    refute_permit @superadmin, @department_manager.profile, 'destroy?'
  end

  test 'Show: social_worker can only show her own profile' do
    refute_permit @social_worker, @superadmin.profile, 'show?'
  end

  test 'Show: department manager can only her own profile' do
    refute_permit @department_manager, @superadmin.profile, 'show?'
  end

  test 'Show: superadmin can show all profiles' do
    Profile.all.each do |profile|
      assert_permit @superadmin, profile, 'show?'
    end
  end
end
