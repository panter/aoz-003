require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  test 'has valid factory' do
    profile = build :profile
    assert profile.valid?
  end

  test 'profile invalid with no first name' do
    profile = build :profile
    profile.first_name = ''
    assert_not profile.valid?
  end

  test 'profile invalid with no last name' do
    profile = build :profile
    profile.last_name = ''
    assert_not profile.valid?
  end
end
