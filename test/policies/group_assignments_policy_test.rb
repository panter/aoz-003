require 'test_helper'

class GroupAssignmentPolicyTest < PolicyAssertions::Test
  def setup
    @volunteer = create :volunteer_with_user
    @superadmin = create :user
    @other_volunteer = create :volunteer_with_user
    @department_manager = create :department_manager
    @group_offer = create :group_offer, department: @department_manager.department.first
    @group_assignment = GroupAssignment.create(volunteer: @volunteer, group_offer: @group_offer)
    @other_group_assignment = GroupAssignment.create(volunteer: @other_volunteer, group_offer: @other_group_offer)
  end

  test 'superadmin can use all actions' do
    assert_permit(
      @superadmin, @group_assignment, @other_group_assignment,
      'show?', 'last_submitted_hours_and_feedbacks?'
      )
  end

  test 'volunteer has limited access' do
    assert_permit(@volunteer, @group_assignment, 'last_submitted_hours_and_feedbacks?')
    refute_permit(@volunteer, @other_group_assignment, 'last_submitted_hours_and_feedbacks?')
  end
end
