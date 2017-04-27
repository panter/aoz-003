require 'test_helper'

class UserPolicyTest < ActiveSupport::TestCase
  def setup
    @user_superadmin = create :user, :with_clients, :with_profile
    @user_social_worker = create :user, :with_clients, :with_profile, role: 'social_worker'
  end

  test 'New: superadmin can create user' do
    user_params = {
      email: 'testuser@excample.com',
      role: 'superadmin'
    }
    assert permit(@user_superadmin, User.new(user_params), :new)
  end

  test 'New: social_worker can not create user' do
    user_params = {
      email: 'testuser@excample.com',
      role: 'superadmin'
    }
    assert_not permit(@user_social_worker, User.new(user_params), :new)
  end

  test 'Update: user can update herself' do
    assert permit(@user_social_worker, @user_social_worker, :update)
  end

  test 'Update: user can not update other user' do
    assert_not permit(@user_social_worker, @user_superadmin, :update)
  end

  test 'Update: superadmin can update other user' do
    assert permit(@user_superadmin, @user_social_worker, :update)
  end
end
