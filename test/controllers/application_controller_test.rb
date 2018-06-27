require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  def setup
    @superadmin = create :user
    @department_manager = create :department_manager
    @social_worker = create :social_worker
    @volunteer = create(:volunteer).user
  end

  test 'redirect user by role on sign in' do
    [@superadmin, @department_manager, @social_worker, @volunteer].each do |user|
      login_as user
      get root_path

      if user.superadmin? || user.department_manager?
        assert_redirected_to volunteers_path
      elsif user.social_worker?
        assert_redirected_to clients_path
      elsif user.volunteer?
        assert_redirected_to profile_path(user)
      end
    end
  end
end
