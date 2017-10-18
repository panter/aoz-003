require 'test_helper'

class FeedbackPolicyTest < PolicyAssertions::Test
  test 'superadmin can use all actions' do
    assert_permit(create(:user), Feedback, 'new?', 'create?', 'index?', 'show?', 'edit?',
      'update?', 'destroy?')
  end

  test 'social worker and department manager have no access' do
    refute_permit(create(:social_worker), Feedback, 'new?', 'create?', 'index?', 'show?',
      'edit?', 'update?', 'destroy?')
    refute_permit(create(:department_manager), Feedback, 'new?', 'create?', 'index?',
      'show?', 'edit?', 'update?', 'destroy?')
  end

  test 'volunteer has limited access' do
    user_volunteer = create :user_volunteer
    volunteer = create :volunteer, user: user_volunteer
    foreign_feedback = create :feedback, volunteer: volunteer, author: create(:user)
    feedback_volunteer = create :feedback, volunteer: volunteer, author: user_volunteer
    refute_permit(user_volunteer, foreign_feedback, 'show?', 'edit?', 'update?', 'destroy?')
    assert_permit(user_volunteer, feedback_volunteer, 'index?', 'show?', 'edit?', 'update?',
      'destroy?')
  end
end
