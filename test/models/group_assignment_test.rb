require 'test_helper'

class GroupAssignmentTest < ActiveSupport::TestCase
  test 'submit_feedback_setter_works_correctly' do
    group_assignment = create :group_assignment
    group_assignment.update(submit_feedback: group_assignment.volunteer.user)
    assert_equal group_assignment.volunteer.user, group_assignment.submitted_by
    refute_nil group_assignment.submitted_at
  end
end
