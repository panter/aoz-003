require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @superadmin = create :user, role: 'superadmin'
  end

  test "non superadmins should not be allowed to update others" do
    roles = User::ROLES.dup
    (roles - ['superadmin']).each_with_index do |role, i|
      params = {
        user: { email: "somebody_#{i}@example.com", role: role }
      }
      user = create_user(role: role)

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
      params = {
        user: { email: "somebody_#{i}@example.com", role: :superadmin }
      }
      user = create_user(role: role)

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
      params = {
        user: { email: "somebody_#{i}@example.com", password: 'sekret' }
      }
      user = create_user(role: role)
      old_encrypted_password = user.encrypted_password

      login_as @superadmin
      put user_path(user), params: params

      refute_equal old_encrypted_password, user.reload.encrypted_password
      assert_equal params[:user][:email], user.email
      assert_response :redirect
    end
  end

  private

  def create_user(role:)
    user = nil

    if role == 'volunteer'
      user = create(:user, :volunteer)
      user.volunteer = create :volunteer
    else
      user = create(:user)
    end

    user.update role: role
    user
  end
end
