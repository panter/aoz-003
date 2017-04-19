require 'test_helper'

class SuperadminCanCreateSuperadminTest < ActionDispatch::IntegrationTest
  def setup
    @superadmin = create :user_with_profile
    login_as(@superadmin)
    @users_count = User.count
  end

  test 'invalid superadmin information' do
    assert_no_difference 'User.count' do
      post users_path, params: { user: { email:  '',
                                         role:   '' } }
    end
    assert_equal User.count, @users_count
  end

  test 'invalid user role' do
    assert_no_difference 'User.count' do
      post users_path, params: { user: { email: 'superadmin@integration.ch',
                                         role:  '' } }
    end
    assert_equal User.count, @users_count
  end

  test 'valid superadmin registration' do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { email: 'superadmin@integration.ch',
                                         role:  'superadmin' } }
    end
    subject_user = User.find_by email: 'superadmin@integration.ch'
    assert_equal subject_user.email, 'superadmin@integration.ch'
  end
end
