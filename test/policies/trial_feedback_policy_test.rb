require 'test_helper'

class TrialFeedbackPolicyTest < PolicyAssertions::Test
  def setup
    @volunteer = create :volunteer_with_user
    @user_volunteer = @volunteer.user
    @superadmin = create :user
    @other_volunteer = create :volunteer_with_user
  end

  test 'superadmin can use all actions' do
    assert_permit(create(:user), TrialFeedback, 'new?', 'create?', 'index?', 'show?', 'edit?',
      'update?', 'destroy?', 'superadmin_privileges?')
  end

  test 'social worker and department manager have no access' do
    refute_permit(create(:social_worker), TrialFeedback, 'new?', 'create?', 'index?', 'show?',
      'edit?', 'update?', 'destroy?', 'superadmin_privileges?')
    refute_permit(create(:department_manager), TrialFeedback, 'new?', 'create?', 'index?',
      'show?', 'edit?', 'update?', 'destroy?', 'superadmin_privileges?')
  end

  test 'volunteer has limited access to assignment feedbacks' do
    assignment = create :assignment, volunteer: @volunteer
    other_assignment = create :assignment, volunteer: @other_volunteer
    superadmin_feedback = create :trial_feedback, volunteer: @volunteer, author: @superadmin,
      trial_feedbackable: assignment
    feedback_volunteer = create :trial_feedback, volunteer: @volunteer, author: @user_volunteer,
      trial_feedbackable: assignment
    foreign_feedback = create :trial_feedback, trial_feedbackable: other_assignment,
      volunteer: @other_volunteer, author: @other_volunteer.user
    refute_permit(@user_volunteer, superadmin_feedback, 'show?', 'edit?', 'update?', 'destroy?',
      'superadmin_privileges?')
    refute_permit(@user_volunteer, foreign_feedback, 'show?', 'edit?', 'update?', 'destroy?',
      'new?', 'create?', 'superadmin_privileges?')
    assert_permit(@user_volunteer, feedback_volunteer, 'index?', 'show?', 'edit?', 'update?',
      'destroy?', 'new?', 'create?')
    refute_permit(@user_volunteer, feedback_volunteer, 'superadmin_privileges?')
  end

  test 'volunteer has limited access to group_offer feedbacks' do
    group_offer = create :group_offer, volunteers: [@volunteer, @other_volunteer]
    other_group_offer = create :group_offer,
      volunteers: [create(:volunteer_with_user), @other_volunteer]
    superadmin_feedback = create :trial_feedback, volunteer: @volunteer, author: @superadmin,
      trial_feedbackable: group_offer
    feedback_volunteer = create :trial_feedback, volunteer: @volunteer, author: @user_volunteer,
      trial_feedbackable: group_offer
    foreign_feedback = create :trial_feedback, volunteer: @other_volunteer,
      author: @other_volunteer.user, trial_feedbackable: other_group_offer
    refute_permit(@user_volunteer, superadmin_feedback, 'show?', 'edit?', 'update?', 'destroy?',
      'superadmin_privileges?')
    refute_permit(@user_volunteer, foreign_feedback, 'show?', 'edit?', 'update?', 'destroy?',
      'new?', 'create?', 'superadmin_privileges?')
    assert_permit(@user_volunteer, feedback_volunteer, 'index?', 'show?', 'edit?', 'update?',
      'destroy?', 'new?', 'create?')
    refute_permit(@user_volunteer, feedback_volunteer, 'superadmin_privileges?')
  end
end
