require 'test_helper'

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    create :profile unless User.find_by email: 'superadmin@example.com'
    @superadmin = User.find_by email: 'superadmin@example.com'
    @noprofile = create :user_noprofile
  end

  test 'should get new' do
    login_as @noprofile, scope: :user
    get new_profile_path
    assert_response :success
  end

  test 'should show profile' do
    login_as @superadmin, scope: :user
    get profile_path(@superadmin.profile.id)
    assert_response :success
  end

  test 'should get edit' do
    login_as @superadmin, scope: :user
    get edit_profile_path(@superadmin.profile.id)
    assert_response :success
  end
end
