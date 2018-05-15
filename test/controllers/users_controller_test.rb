require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @superadmin = create :user, role: 'superadmin'
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
    roles = User::ROLES.dup
    (roles - ['superadmin']).each_with_index do |role, i|
      user = role == 'volunteer' ? create(:user, :volunteer) : create(:user)
      params = {
        user: { email: "somebody_#{i}@example.com", password: 'sekret' }
      }
      user.update role: role
      old_encrypted_password = user.encrypted_password

      login_as @superadmin
      put user_path(user), params: params

      refute_equal old_encrypted_password, user.reload.encrypted_password
      assert_equal params[:user][:email], user.email
      assert_response :redirect
    end
  end
end
