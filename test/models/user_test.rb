require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = build :user
    @user_as_superadmin = create :user, :with_profile, role: 'superadmin'
    @admin = create :user, :with_profile, role: 'admin'
    @user_as_social_worker = create :user, :with_profile, role: 'social_worker'
  end

  test 'valid factory' do
    assert @user.valid?
  end

  test '#create_user_and_send_password_reset \
    with new email creates new superadmin' do

    assert_difference 'User.count', 1 do
      User.create_user_and_send_password_reset email: 'superadmin@example.com',
        role: 'superadmin'
    end

    user = User.find_by email: 'superadmin@example.com'

    assert_equal user.email, 'superadmin@example.com'
    assert_equal user.role, 'superadmin'
  end

  test '#create_user_and_send_password_reset \
    with taken email does not create superadmin' do
    create :user, email: 'superadmin@example.com'

    capture_io do
      assert_raises(ActiveRecord::RecordInvalid) do
        User.create_user_and_send_password_reset email: 'superadmin@example.com',
          role: 'superadmin'
      end
    end
  end

  test '@user_as_superadmin.superadmin? returns true if user is superadmin' do
    assert @user_as_superadmin.superadmin?
  end

  test '@user_as_superadmin.admin?, .social_worker? returns false' do
    refute @user_as_superadmin.admin?
    refute @user_as_superadmin.social_worker?
  end

  test '@admin.admin? returns true if user is admin' do
    assert @user_as_superadmin.superadmin?
  end

  test '@admin.superadmin?, .social_worker? returns false' do
    refute @admin.superadmin?
    refute @admin.social_worker?
  end

  test '@user_as_social_worker.social_worker? returns true if user is of role socialworker' do
    assert @user_as_social_worker.social_worker?
  end

  test '@user_as_social_worker.superadmin?, .admin? returns false' do
    refute @user_as_social_worker.superadmin?
    refute @user_as_social_worker.admin?
  end

  context 'associations' do
    should have_many(:clients)
  end
end
