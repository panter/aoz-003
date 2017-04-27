require 'test_helper'

class UserPolicyTest < ActiveSupport::TestCase
  def setup
    @user_superadmin = create :user, :with_clients, :with_profile
    @user_social_worker = create :user, :with_clients, :with_profile, role: 'social_worker'
  end

  test 'New: superadmin can create user' do
    assert_permit @user_superadmin, User, 'new?', 'create?'
  end

  test 'New: social_worker can not create user' do
    refute_permit @user_social_worker, User, 'create?', 'new?'
  end

  test 'Update: user can update herself' do
    assert_permit @user_social_worker, @user_social_worker, 'update?', 'edit?'
  end

  test 'Update: user can not update other user' do
    refute_permit @user_social_worker, @user_superadmin, 'update?', 'edit?'
  end

  test 'Update: superadmin can update other user' do
    assert_permit @user_superadmin, @user_social_worker, 'update?', 'edit?'
  end

  test 'Show: staff can show users' do
    User.all.each do |user|
      assert_permit @user_superadmin, user, 'show?'
    end
  end
end
