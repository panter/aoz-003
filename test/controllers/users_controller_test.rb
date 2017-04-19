require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = create :user_with_profile
  end

  test "should redirect create new user creation when not logged in" do
    get new_user_path
    assert_redirected_to new_user_session_path
  end

  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to new_user_session_path
  end

  test "should redirect show user when not logged in" do
    get user_path(@user)
    assert_redirected_to new_user_session_path
  end
end
