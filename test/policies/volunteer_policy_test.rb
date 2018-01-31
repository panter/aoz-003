require 'test_helper'

class VolunteerPolicyTest < PolicyAssertions::Test
  def setup
    @actions = ['index?', 'search?', 'new?', 'create?', 'seeking_clients?', 'terminate?', 'show?',
                'edit?', 'update?', 'show_acceptance?', 'superadmin_privileges?']
  end

  test 'superadmin_can_use_all_actions' do
    assert_permit(create(:user), Volunteer, *@actions)
  end

  test 'department_manager_has_limited_access' do
    department_manager = create :department_manager
    department_manager_volunteer = create :volunteer_with_user
    department_manager_volunteer.registrar = department_manager
    assert_permit(department_manager, Volunteer, *@actions[0..4], *@actions[-2])
    assert_permit(department_manager, department_manager_volunteer, *@actions[5..8])
    refute_permit(department_manager, create(:volunteer), *@actions[5..8])
    refute_permit(department_manager, Volunteer, *@actions[-1])
  end

  test 'social_worker_has_no_access' do
    social_worker = create :social_worker
    refute_permit(social_worker, Volunteer, *@actions)
  end

  test 'volunteer_has_limited_access' do
    volunteer_one = create :volunteer_with_user
    volunteer_two = create :volunteer_with_user
    assert_permit(volunteer_one.user, volunteer_one, *@actions[6..8])
    refute_permit(volunteer_one.user, volunteer_two, *@actions[6..8])
    refute_permit(volunteer_one.user, Volunteer, *@actions[0..5], *@actions[9..-1])
  end
end
