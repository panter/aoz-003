require 'test_helper'

class SuperadminCanCreateSuperadminTest < ActionDispatch::IntegrationTest
  def setup
    @user = build :user
  end

  test 'invalid superadmin information' do
    login_as(@user)
    get new_user_path
    assert_no_difference 'User.count' do
    post users_path, params: { user: { email:  '',
                                       role:   '' } }
    end
  end

  test 'invalid user role' do
    login_as(@user)
    get new_user_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { email: 'superadmin@integration.ch',
                                         role:  'abrakadabra' } }
    end
  end

  # test 'valid superadmin registration' do
  #  login_as(@user)
  #  get new_user_path
  #  assert_difference 'User.count', 1 do
  #    post users_path, params: { user: { email: 'superadmin@abc.ch',
  #                                       role:  'superadmin' } }
  #  end
  # end
end
