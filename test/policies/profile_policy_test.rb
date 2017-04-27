require 'test_helper'

class ProfilePolicyTest < ActiveSupport::TestCase
  def setup
    @user_superadmin = create :user, :with_clients, :with_profile
    @user_social_worker = create :user, :with_clients, :with_profile, role: 'social_worker'
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
    assert_permit @user_social_worker, @user_social_worker.profile, 'update?', 'edit?'
  end

  test 'Update: user can not update others profile' do
    refute_permit @user_social_worker, @user_superadmin.profile, 'update?', 'edit?'
  end

  test 'Update: superadmin can update others profile' do
    assert_permit @user_superadmin, @user_social_worker.profile, 'update?', 'edit?'
  end

  test 'Destroy: profiles can not be destroyed' do
    refute_permit @user_superadmin, @user_superadmin.profile, 'destroy?'
  end

  test 'Show: social_worker can only show his own profile' do
    refute_permit @user_social_worker, @user_superadmin.profile, 'show?'
  end

  test 'Show: superadmin can show all profiles' do
    Profile.all.each do |profile|
      assert_permit @user_superadmin, profile, 'show?'
    end
  end
end
