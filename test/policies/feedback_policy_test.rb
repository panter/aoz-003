require 'test_helper'

class FeedbackPolicyTest < PolicyAssertions::Test
  def setup
    @volunteer = create :volunteer
    @user_volunteer = @volunteer.user
    @superadmin = create :user
    @other_volunteer = create :volunteer
  end

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

  test 'volunteer has limited access to assignment feedbacks' do
    assignment = create :assignment, volunteer: @volunteer
    other_assignment = create :assignment, volunteer: @other_volunteer
    superadmin_feedback = create :feedback, volunteer: @volunteer, author: @superadmin,
      feedbackable: assignment
    feedback_volunteer = create :feedback, volunteer: @volunteer, author: @user_volunteer,
      feedbackable: assignment
    foreign_feedback = create :feedback, feedbackable: other_assignment,
      volunteer: @other_volunteer, author: @other_volunteer.user
    refute_permit(@user_volunteer, superadmin_feedback, 'destroy?')
    assert_permit(@user_volunteer, superadmin_feedback, 'show?', 'edit?', 'update?')
    refute_permit(@user_volunteer, foreign_feedback, 'show?', 'edit?', 'update?', 'destroy?',
      'new?', 'create?')
    assert_permit(@user_volunteer, feedback_volunteer, 'index?', 'show?', 'edit?', 'update?',
      'destroy?', 'new?', 'create?')
  end

  test 'volunteer_has_limited_access_to_group_offer_feedbacks' do
    group_offer = create :group_offer
    create :group_assignment, volunteer: @volunteer, group_offer: group_offer
    create :group_assignment, volunteer: @other_volunteer, group_offer: group_offer
    other_group_offer = create :group_offer
    create :group_assignment, volunteer: create(:volunteer), group_offer: other_group_offer
    create :group_assignment, volunteer: @other_volunteer, group_offer: other_group_offer

    superadmin_feedback = create :feedback, volunteer: @volunteer, author: @superadmin,
      feedbackable: group_offer
    feedback_volunteer = create :feedback, volunteer: @volunteer, author: @user_volunteer,
      feedbackable: group_offer
    foreign_feedback = create :feedback, volunteer: @other_volunteer, author: @other_volunteer.user,
      feedbackable: other_group_offer
    refute_permit(@user_volunteer, superadmin_feedback, 'destroy?')
    assert_permit(@user_volunteer, superadmin_feedback, 'show?', 'edit?', 'update?')
    refute_permit(@user_volunteer, foreign_feedback, 'show?', 'edit?', 'update?', 'destroy?',
      'new?', 'create?')
    assert_permit(@user_volunteer, feedback_volunteer, 'index?', 'show?', 'edit?', 'update?',
      'destroy?', 'new?', 'create?')
  end
end
