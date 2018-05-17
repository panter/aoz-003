require 'test_helper'

class ListResponsePolicyTest < PolicyAssertions::Test
  test 'only superadmin can use all actions' do
    assert_permit create(:user), :list_response,
      'feedbacks?', 'trial_feedbacks?'
    refute_permit create(:volunteer).user, :list_response,
      'feedbacks?', 'trial_feedbacks?'
    refute_permit create(:department_manager), :list_response,
      'feedbacks?', 'trial_feedbacks?'
    refute_permit create(:social_worker), :list_response,
      'feedbacks?', 'trial_feedbacks?'
  end
end
