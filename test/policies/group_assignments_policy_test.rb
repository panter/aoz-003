require 'test_helper'

class GroupAssignmentPolicyTest < PolicyAssertions::Test
  test 'superadmin_can_use_all_actions' do
    assert_permit(create(:user), GroupAssignment, *actions_list, 'show_comments?')
  end

  test 'department_manager without department has read-only access' do
    department_manager_without_department = create :department_manager_without_department
    group_offer = create :group_offer
    group_assignment = create :group_assignment, group_offer: group_offer

    assert_permit(department_manager_without_department, GroupAssignment, index_actions)
    assert_permit(department_manager_without_department, group_assignment, *show_actions, :show_comments?)

    refute_permit(department_manager_without_department, group_assignment, new_actions)
    refute_permit(department_manager_without_department, group_assignment, edit_actions)
  end

  test 'department_manager has full access in their departments but limited in others' do
    department_manager = create :department_manager
    group_offer = create :group_offer, department: department_manager.department.last
    group_assignment = create :group_assignment, group_offer: group_offer
    other_group_offer = create :group_offer
    other_group_assignment = create :group_assignment, group_offer: other_group_offer

    assert_permit(department_manager, GroupAssignment, index_actions)

    assert_permit(department_manager, group_assignment, new_actions)

    assert_permit(department_manager, group_assignment, *show_actions, 'show_comments?')
    assert_permit(department_manager, other_group_assignment, *show_actions, 'show_comments?')

    assert_permit(department_manager, group_assignment, edit_actions)
    refute_permit(department_manager, other_group_assignment, edit_actions)
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
        :terminate, :submit_feedback, :show, :update_terminated_at,
        :last_submitted_hours_and_feedbacks, :hours_and_feedbacks_submitted
      ))
    refute_permit(volunteer.user, create(:group_assignment),
      'show_comments?', *actions_list(
        :terminate, :submit_feedback, :show, :update_terminated_at,
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

  def new_actions
    actions_list(:create)
  end

  def edit_actions
    actions_list(
      :edit,
      :update,
      :submit_feedback,
      :update_terminated_at,
      :set_end_today,
      :terminate,
      :verify_termination
    )
  end
end
