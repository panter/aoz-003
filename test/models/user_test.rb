require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = build :user
  end

  test 'valid factory' do
    assert @user.valid?
  end

  test 'email should be present' do
    @user.email = ' '
    assert_not @user.valid?
  end

  test 'role should be present' do
    @user.role = '  '
    assert_not @user.valid?
  end

  test 'password should be present' do
    @user.password = '  '
    assert_not @user.valid?
  end

  test 'password should be present (nonblank)' do
    @user.password = @user.password_confirmation = ' ' * 6
    assert_not @user.valid?
  end

  test 'password should have a minimum length' do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?
  end

  test 'email addresses should be unique' do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test '#create_user_and_send_password_reset \
    with new email creates new superadmin' do
    out, err = capture_io do
      assert_difference 'User.count', 1 do
        User.create_user_and_send_password_reset email: 'superadmin@example.com',
          role: User::SUPERADMIN
      end
    end

    assert_equal out, "Mail sent to superadmin@example.com\n"

    user = User.first

    assert_equal user.email, 'superadmin@example.com'
    assert_equal user.role, 'superadmin'
  end

  test '#create_user_and_send_password_reset \
    with taken email does not create superadmin' do
    create :user

    capture_io do
      assert_raises(ActiveRecord::RecordInvalid) do
        User.create_user_and_send_password_reset email: 'superadmin@example.com',
          role: User::SUPERADMIN
      end
    end
  end

  context "associations" do
    should have_many(:clients)
  end
end
