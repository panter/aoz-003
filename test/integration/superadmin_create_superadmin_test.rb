require 'test_helper'

class SuperadminCanCreateSuperadminTest < ActionDispatch::IntegrationTest
  def setup
    @user = create :user
    login_as(@user)
  end

  test 'invalid superadmin information' do
    assert_no_difference 'User.count' do
      post users_path, params: { user: { email:  '',
                                         role:   '' } }
    end
    assert_equal User.last, @user
  end

  test 'invalid user role' do
    assert_no_difference 'User.count' do
      post users_path, params: { user: { email: 'superadmin@integration.ch',
                                         role:  '' } }
    end
    assert_equal User.last, @user
  end

  test 'valid superadmin registration' do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { email: 'superadmin@integration.ch',
                                         role:  'superadmin' } }
    end
    assert_equal User.last.email, 'superadmin@integration.ch'
  end
end
