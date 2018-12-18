require 'test_helper'

class FeedbackPolicyTest < PolicyAssertions::Test
  def setup
    @volunteer = create :volunteer
    @user_volunteer = @volunteer.user
    @superadmin = create :user
    @other_volunteer = create :volunteer
  end

  test 'superadmin can use all actions' do
    assert_permit(create(:user), Feedback, 'index?')
  end

  test 'social worker and department manager have no access' do
    refute_permit(create(:social_worker), Feedback, 'index?')
    refute_permit(create(:department_manager), Feedback, 'index?')
  end
end
