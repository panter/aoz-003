require 'test_helper'

class AssignmentPolicyTest < PolicyAssertions::Test
  test 'superadmin_can_use_all_actions' do
    assert_permit(create(:user), Assignment, *actions_list, 'show_comments?')
  end

  test 'department_manager_has_limited_access' do
    department_manager = create(:department_manager)
    assignment_department_manager = create :assignment, creator: department_manager
    assert_permit(department_manager, Assignment,
      'show_comments?', *actions_list(
        :index, :terminated_index, :volunteer_search, :client_search, :new, :create,
        :hours_and_feedbacks_submitted
      ))
    assert_permit(department_manager, assignment_department_manager,
      'show_comments?', *actions_list(
        :find_client, :show, :edit, :update,
        :terminate, :update_terminated_at,
        :submit_feedback, :last_submitted_hours_and_feedbacks
      ))
    refute_permit(department_manager, create(:assignment),
      *actions_list(
        :show, :edit, :update, :submit_feedback, :terminate,
        :update_terminated_at, :last_submitted_hours_and_feedbacks
      ))
    refute_permit(department_manager, Assignment, *actions_list(:verify_termination))
  end

  test 'social worker has limited access' do
    social_worker = create :social_worker
    client = create :client, user: social_worker
    assignment = create(:assignment, client: client)
    assert_permit social_worker, assignment, *actions_list(:show)

    client = create :client, involved_authority: social_worker
    assignment = create(:assignment, client: client)
    assert_permit social_worker, assignment, *actions_list(:show)

    refute_permit social_worker, Assignment, *actions_list, 'show_comments?'
  end

  test 'volunteer_has_limited_access' do
    volunteer = create :volunteer
    assignment = create :assignment, volunteer: volunteer
    other_assignment = create :assignment, volunteer: (create :volunteer)
    assert_permit(volunteer.user, assignment,
      *actions_list(
        :show, :last_submitted_hours_and_feedbacks, :submit_feedback,
        :hours_and_feedbacks_submitted, :terminate
      ))
    refute_permit(volunteer.user, Assignment,
      'show_comments?', *actions_list(
        :index, :terminated_index, :volunteer_search, :client_search,
        :new, :create, :edit, :update,
        :terminate, :update_terminated_at, :verify_termination
      ))
    refute_permit(volunteer.user, other_assignment,
      'show_comments?', *actions_list(except: [:hours_and_feedbacks_submitted]))
  end
end
