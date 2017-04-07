require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'valid factory' do
    user = build :user

    assert user.valid?
  end
end
