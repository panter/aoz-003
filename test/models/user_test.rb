require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = create :user
    @superadmin = create :user, role: 'superadmin'
    @social_worker = create :user, role: 'social_worker'
    @department_manager = create :user, role: 'department_manager'
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

  test '@superadmin.superadmin? returns true if user is superadmin' do
    assert @superadmin.superadmin?
  end

  test '@superadmin.social_worker? returns false' do
    refute @superadmin.social_worker?
  end

  test '@social_worker.social_worker? returns true if user is of role socialworker' do
    assert @social_worker.social_worker?
  end

  test '@social_worker.superadmin? returns false' do
    refute @social_worker.superadmin?
  end

  test '@department_manager.superadmin? .social_worker? returns false' do
    refute @department_manager.superadmin?
    refute @department_manager.social_worker?
  end

  test 'record still exists after deletion' do
    user = create :user, role: 'social_worker'

    assert_difference 'User.count', -1 do
      user.destroy
    end

    assert User.unscoped.find(user.id)
  end

  test 'validates uniqueness only checks non deleted records' do
    a = User.create!(email: 'superadmin@example.com', role: 'superadmin', password: 'asdfasdf')
    a.destroy
    b = User.new(email: 'superadmin@example.com', role: 'superadmin', password: 'asdfasdf')
    assert b.valid?
  end

  test 'validates uniqueness still works on non deleted records' do
    a = User.create!(email: 'superadmin@example.com', role: 'superadmin', password: 'asdfasdf')
    b = User.new(email: 'superadmin@example.com', role: 'superadmin', password: 'asdfasdf')
    refute b.valid?
  end

  test 'automatically builds profile relation' do
    assert_instance_of Profile, @user.profile
  end

  test 'automatically assigns primary email on contact' do
    assert_equal @user.profile.contact.primary_email, @user.email
  end
end
