require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @superadmin = create :user, role: 'superadmin'
    @social_worker = create :user, role: 'social_worker'
    @department_manager = create :department_manager
  end

  test "non superadmins should not be allowed to update others" do
    roles = User::ROLES.dup
    (roles - ['superadmin']).each_with_index do |role, i|
      user = role == 'volunteer' ? create(:user, :volunteer) : create(:user)
      params = {
        user: { email: "somebody_#{i}@example.com", role: role }
      }
      user.update role: role

      login_as user
      put user_path(@superadmin), params: params

      refute @superadmin.reload.send("#{role}?")
      refute_equal params[:user][:email], @superadmin.email
      assert_response :redirect
    end
  end

  test "non superadmins should not be allowed to edit their own rule" do
    roles = User::ROLES.dup
    (roles - ['superadmin']).each_with_index do |role, i|
      user = role == 'volunteer' ? create(:user, :volunteer) : create(:user)
      params = {
        user: { email: "somebody_#{i}@example.com", role: :superadmin }
      }
      user.update role: role

      login_as user
      put user_path(user), params: params

      refute user.reload.superadmin?
      assert_equal params[:user][:email], user.email
      assert_response :redirect
    end
  end

  test "superadmin should be allowed to update other users" do
    old_encrypted_password = @department_manager.encrypted_password
    params = {
      user: { email: 'somebody@example.com', password: 'sekret' }
    }

    login_as @superadmin
    put user_path(@department_manager), params: params

    refute_equal old_encrypted_password, @department_manager.reload.encrypted_password
    assert_equal params[:user][:email], @department_manager.email
    assert_response :redirect
  end
end
