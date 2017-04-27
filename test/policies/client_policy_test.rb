require 'test_helper'

class ClientPolicyTest < ActiveSupport::TestCase
  def setup
    @user_superadmin = create :user, :with_clients
    @user_social_worker = create :user, :with_clients, role: 'social_worker'
  end

  test 'Create: superadmin can create' do
    assert permit(@user_superadmin, Client.new, :new)
  end

  test 'Create: social_worker can create' do
    assert permit(@user_social_worker, Client.new, :new)
  end

  test 'Destroy: superadmin can destroy' do
    assert permit(@user_superadmin, Client.first, :destroy)
  end

  test 'Destroy: social_worker can not destroy' do
    assert_not permit(@user_social_worker, Client.first, :destroy)
  end

  test 'Update: superadmin can update her client' do
    assert permit(@user_superadmin, @user_superadmin.clients.first, :update)
  end

  test 'Update: superadmin can update others client' do
    assert permit(@user_superadmin, @user_social_worker.clients.first, :update)
  end

  test 'Update: social_worker can update her client' do
    assert permit(@user_social_worker, @user_social_worker.clients.first, :update)
  end

  test 'Update: social_worker can not update others client' do
    assert_not permit(@user_social_worker, @user_superadmin.clients.first, :update)
  end
end
