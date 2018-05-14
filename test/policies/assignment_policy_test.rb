require 'test_helper'

class AssignmentPolicyTest < PolicyAssertions::Test
  test 'superadmin_can_use_all_actions' do
    assert_permit(create(:user), Assignment, *actions_list, 'comments?')
  end

  test 'department_manager_has_limited_access' do
    department_manager = create(:department_manager)
    assignment_department_manager = create :assignment, creator: department_manager
    assert_permit(department_manager, Assignment,
      'comments?', *actions_list(
        :index, :terminated_index, :volunteer_search, :client_search, :new, :create,
        :hours_and_feedbacks_submitted
      ))
    assert_permit(department_manager, assignment_department_manager,
      'comments?', *actions_list(
        :find_client, :show, :edit, :update,
        :terminate, :update_terminated_at,
        :update_submitted_at, :last_submitted_hours_and_feedbacks
      ))
    refute_permit(department_manager, create(:assignment),
      *actions_list(
        :show, :edit, :update, :update_submitted_at, :terminate,
        :update_terminated_at, :last_submitted_hours_and_feedbacks
      ))
    refute_permit(department_manager, Assignment, *actions_list(:verify_termination))
  end

  test 'social_worker_has_no_access' do
    refute_permit(create(:social_worker), Assignment, *actions_list, 'comments?')
  end

  test 'volunteer_has_limited_access' do
    volunteer = create :volunteer_with_user
    assignment = create :assignment, volunteer: volunteer
    other_assignment = create :assignment, volunteer: (create :volunteer_with_user)
    assert_permit(volunteer.user, assignment,
      *actions_list(
        :show, :last_submitted_hours_and_feedbacks, :update_submitted_at,
        :hours_and_feedbacks_submitted
      ))
    refute_permit(volunteer.user, Assignment,
      'comments?', *actions_list(
        :index, :terminated_index, :volunteer_search, :client_search,
        :new, :create, :edit, :update,
        :terminate, :update_terminated_at, :verify_termination
      ))
    refute_permit(volunteer.user, other_assignment,
      'comments?', *actions_list(except: [:hours_and_feedbacks_submitted]))
  end
end
