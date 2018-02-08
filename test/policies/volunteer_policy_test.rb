require 'test_helper'

class VolunteerPolicyTest < PolicyAssertions::Test
  test 'superadmin_can_use_all_actions' do
    assert_permit(create(:user), Volunteer, 'superadmin_privileges?', *actions_list.values)
  end

  test 'department_manager_has_limited_access' do
    department_manager = create :department_manager
    department_manager_volunteer = create :volunteer_with_user
    department_manager_volunteer.registrar = department_manager
    assert_permit(department_manager, Volunteer, 'show_acceptance?',
      *actions_list(:index, :search, :new, :create, :seeking_clients))
    assert_permit(department_manager, department_manager_volunteer,
      *actions_list(:terminate, :show, :edit, :update))
    refute_permit(department_manager, create(:volunteer),
      *actions_list(:terminate, :show, :edit, :update))
    refute_permit(department_manager, Volunteer, 'superadmin_privileges?')
  end

  test 'social_worker_has_no_access' do
    refute_permit(create(:social_worker), Volunteer, *actions_list.values)
  end

  test 'volunteer_has_limited_access' do
    volunteer_one = create :volunteer_with_user
    volunteer_two = create :volunteer_with_user
    assert_permit(volunteer_one.user, volunteer_one, *actions_list(:show, :edit, :update))
    refute_permit(volunteer_one.user, volunteer_two, *actions_list(:show, :edit, :update))
    refute_permit(volunteer_one.user, Volunteer, 'superadmin_privileges?', 'show_acceptance?',
      *actions_list(:index, :search, :new, :create, :seeking_clients, :terminate))
    refute_permit(volunteer_two.user, Volunteer, 'superadmin_privileges?', 'show_acceptance?',
      *actions_list(:index, :search, :new, :create, :seeking_clients, :terminate))
  end
end
