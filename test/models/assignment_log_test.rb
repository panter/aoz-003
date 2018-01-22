require 'test_helper'

class AssignmentLogTest < ActiveSupport::TestCase
  test 'destroying an assignment creates its copy as assignment_log' do
    assignment = create :assignment, period_start: 2.weeks.ago, period_end: Time.zone.today
    assignment.destroy
    assignment_log = AssignmentLog.last
    assert_equal assignment, assignment_log.assignment
    assert assignment_log.assignment.deleted?
    assert_equal assignment.client, assignment_log.client
    assert_equal assignment.volunteer, assignment_log.volunteer
    assert_equal assignment.creator, assignment_log.creator
  end
end
