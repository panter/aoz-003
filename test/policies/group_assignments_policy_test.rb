require 'test_helper'

class GroupAssignmentPolicyTest < PolicyAssertions::Test
  test 'superadmin_can_use_all_actions' do
    assert_permit(create(:user), GroupAssignment, *actions_list, 'show_comments?')
  end

  test 'department_manager has limited access when set as responsible' do
    department_manager_without_department = create :department_manager_without_department
    department_manager_group_offer = create :group_offer, creator: department_manager_without_department
    department_manager_group_assignment = create :group_assignment, group_offer: department_manager_group_offer
    other_group_offer = create :group_offer
    other_group_assignment = create :group_assignment, group_offer: other_group_offer

    assert_permit(department_manager_without_department, GroupAssignment, index_actions)
    assert_permit(department_manager_without_department, department_manager_group_assignment, *show_actions, :show_comments?)
    assert_permit(department_manager_without_department, department_manager_group_assignment, edit_actions)
    assert_permit(department_manager_without_department, other_group_assignment, show_actions)
    refute_permit(department_manager_without_department, other_group_assignment, edit_actions)
  end

  test 'social_worker_has_no_access' do
    refute_permit(create(:social_worker), GroupAssignment, *actions_list, 'show_comments?')
  end

  test 'volunteer_has_limited_access' do
    volunteer = create :volunteer
    volunteer_group_assignment =  create :group_assignment, volunteer: volunteer
    refute_permit(volunteer.user, GroupAssignment,
      'show_comments?', *actions_list(
        :verify_termination, :terminated_index, :edit, :set_end_today, :update
      ))
    assert_permit(volunteer.user, volunteer_group_assignment,
      *actions_list(
        :terminate, :update_submitted_at, :show, :update_terminated_at,
        :last_submitted_hours_and_feedbacks, :hours_and_feedbacks_submitted
      ))
    refute_permit(volunteer.user, create(:group_assignment),
      'show_comments?', *actions_list(
        :terminate, :update_submitted_at, :show, :update_terminated_at,
        :last_submitted_hours_and_feedbacks
      ))
  end

  private
  def index_actions
    actions_list(:terminated_index, :hours_and_feedbacks_submitted)
  end

  def show_actions
    actions_list(:show, :last_submitted_hours_and_feedbacks)
  end

  def edit_actions
    actions_list(
      :create,
      :edit,
      :update,
      :update_submitted_at,
      :update_terminated_at,
      :set_end_today,
      :terminate,
      :verify_termination
    )
  end
end
