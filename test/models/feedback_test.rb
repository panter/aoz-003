require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase
  test 'since_last_submitted_scope' do
    volunteer = create :volunteer
    assignment = create :assignment, volunteer: volunteer
    feedback = create :feedback, feedbackable: assignment, volunteer: volunteer,
      author: volunteer.user
    feedback_by_superadmin = create :feedback, feedbackable: assignment, volunteer: volunteer,
      author: create(:user)

    assignment_last_submitted = create :assignment, volunteer: volunteer,
      submitted_at: 6.months.ago
    before_last_submitted_feedback = create :feedback, volunteer: volunteer, author: volunteer.user,
      feedbackable: assignment_last_submitted
    before_last_submitted_feedback.update(created_at: 8.months.ago, updated_at: 8.months.ago)
    after_last_submitted_feedback = create :feedback, volunteer: volunteer, author: volunteer.user,
      feedbackable: assignment_last_submitted
    after_last_submitted_feedback.update(created_at: 2.months.ago, updated_at: 2.months.ago)
    before_last_submitted_feedback_superadmin = create :feedback, volunteer: volunteer,
      author: create(:user), feedbackable: assignment_last_submitted
    before_last_submitted_feedback_superadmin.update(created_at: 8.months.ago,
       updated_at: 8.months.ago)
    after_last_submitted_feedback_superadmin = create :feedback, volunteer: volunteer,
      author: create(:user), feedbackable: assignment_last_submitted
    after_last_submitted_feedback_superadmin.update(created_at: 2.months.ago,
      updated_at: 2.months.ago)

    assignment.reload
    assignment_last_submitted.reload

    query_via_assignment = assignment.feedbacks_since_last_submitted
    query_via_feedback = Feedback.where(feedbackable: assignment).since_last_submitted(nil)
    assert query_via_assignment.include? feedback
    refute query_via_assignment.include? feedback_by_superadmin
    assert query_via_feedback.include? feedback
    refute query_via_feedback.include? feedback_by_superadmin

    query_via_assignment = assignment_last_submitted.feedbacks_since_last_submitted
    query_via_feedback = Feedback.where(feedbackable: assignment_last_submitted)
                                 .since_last_submitted(assignment_last_submitted.submitted_at)
    assert query_via_feedback.include? after_last_submitted_feedback
    assert query_via_assignment.include? after_last_submitted_feedback

    refute query_via_assignment.include? before_last_submitted_feedback
    refute query_via_assignment.include? before_last_submitted_feedback_superadmin
    refute query_via_assignment.include? after_last_submitted_feedback_superadmin
    refute query_via_feedback.include? before_last_submitted_feedback
    refute query_via_feedback.include? before_last_submitted_feedback_superadmin
    refute query_via_feedback.include? after_last_submitted_feedback_superadmin
  end
end
