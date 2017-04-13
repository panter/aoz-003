require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'valid factory' do
    user = build :user

    assert user.valid?
  end

  test '#create_user_and_send_password_reset \
    with new email creates new superadmin' do
    out, err = capture_io do
      assert_difference 'User.count', 1 do
        User.create_user_and_send_password_reset email: 'superadmin@example.com'
      end
    end

    assert_equal out, "Mail sent to superadmin@example.com\n"

    user = User.first

    assert_equal user.email, 'superadmin@example.com'
    assert_equal user.role, 'superadmin'
  end

  test '#create_user_and_send_password_reset \
    with taken email does not create superadmin' do
    create :user, email: 'superadmin@example.com'

    capture_io do
      assert_raises(ActiveRecord::RecordInvalid) do
        User.create_user_and_send_password_reset email: 'superadmin@example.com'
      end
    end
  end

  context "associations" do
    should have_many(:clients)
  end
end
