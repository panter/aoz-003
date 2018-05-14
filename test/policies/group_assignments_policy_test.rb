require 'test_helper'

class GroupAssignmentPolicyTest < PolicyAssertions::Test
  test 'superadmin_can_use_all_actions' do
    assert_permit(create(:user), GroupAssignment, *actions_list, 'comments?')
  end

  test 'department_manager_has_limited_access' do
    department_manager = create :department_manager
    department_manager_group_assignment = create :group_assignment,
      group_offer: create(:group_offer, creator: department_manager)
    refute_permit(department_manager, GroupAssignment, *actions_list(:verify_termination))
    assert_permit(department_manager, GroupAssignment, *actions_list(:terminated_index), 'comments?')
    assert_permit(department_manager, department_manager_group_assignment,
      *actions_list(except: [:verify_termination, :terminated_index]), 'comments?')
    refute_permit(department_manager, create(:group_assignment),
      *actions_list(
        except: [:verify_termination, :terminated_index, :hours_and_feedbacks_submitted]
      ))
  end

  test 'social_worker_has_no_access' do
    refute_permit(create(:social_worker), GroupAssignment, *actions_list, 'comments?')
  end

  test 'volunteer_has_limited_access' do
    volunteer = create :volunteer_with_user
    volunteer_group_assignment =  create :group_assignment, volunteer: volunteer
    refute_permit(volunteer.user, GroupAssignment,
      'comments?', *actions_list(
        :verify_termination, :terminated_index, :edit, :set_end_today, :update
      ))
    assert_permit(volunteer.user, volunteer_group_assignment,
      *actions_list(
        :terminate, :update_submitted_at, :show, :update_terminated_at,
        :last_submitted_hours_and_feedbacks, :hours_and_feedbacks_submitted
      ))
    refute_permit(volunteer.user, create(:group_assignment),
      'comments?', *actions_list(
        :terminate, :update_submitted_at, :show, :update_terminated_at,
        :last_submitted_hours_and_feedbacks
      ))
  end
end
