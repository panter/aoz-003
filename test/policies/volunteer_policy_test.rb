require 'test_helper'

class VolunteerPolicyTest < PolicyAssertions::Test
  test 'superadmin_can_use_all_actions' do
    assert_permit(create(:user), Volunteer,
      'superadmin_privileges?', 'show_comments?', *actions_list(except: [:reactivate]))
  end

  test 'department_manager has full access to volunteers in their departments' do
    department_manager = create :department_manager
    department = department_manager.department.last
    volunteer = create :volunteer, department: department

    assert_permit(department_manager, Volunteer, 'show_acceptance?', 'show_comments?',
      *actions_list(:index, :search, :new, :create, :seeking_clients))
    assert_permit(department_manager, volunteer, 'update_acceptance?',
      *actions_list(:terminate, :show, :edit, :update))

    refute_permit(department_manager, Volunteer, 'superadmin_privileges?')
    refute_permit(department_manager, volunteer, *actions_list(:account))
  end

  test 'department_manager has limited access to volunteers in other departments' do
    department_manager = create :department_manager
    volunteer = create :volunteer

    assert_permit(department_manager, Volunteer, 'show_acceptance?', 'show_comments?',
      *actions_list(:index, :search, :new, :create, :seeking_clients))
    assert_permit(department_manager, volunteer, 'show_comments?')

    refute_permit(department_manager, Volunteer, 'superadmin_privileges?')
    refute_permit(department_manager, volunteer,
      *actions_list(:terminate, :show, :edit, :update, :account), 'update_acceptance?')
  end

  test 'department_manager has access to volunteer with acceptence undecided' do
    department_manager = create :department_manager
    volunteer = create :volunteer, acceptance: :undecided

    assert_permit(department_manager, volunteer, 'update_acceptance?',
      *actions_list(:show, :edit, :update))
    refute_permit(department_manager, volunteer, *actions_list(:account, :terminate))
  end

  test 'department_manager has no access to volunteer with acceptence undecided in other departments' do
    department_manager = create :department_manager
    department = create :department
    volunteer = create :volunteer, acceptance: :undecided, department: department

    refute_permit(department_manager, volunteer,
      *actions_list(:terminate, :show, :edit, :update, :account), 'update_acceptance?')
  end

  test 'social_worker_has_no_access' do
    refute_permit(create(:social_worker), Volunteer, *actions_list, 'show_comments?')
  end

  test 'volunteer_has_limited_access' do
    volunteer_one = create :volunteer
    volunteer_two = create :volunteer
    assert_permit(volunteer_one.user, volunteer_one, *actions_list(:show, :edit, :update))
    refute_permit(volunteer_one.user, volunteer_two, *actions_list(:show, :edit, :update))
    refute_permit(volunteer_one.user, Volunteer,
      'superadmin_privileges?', 'show_acceptance?', 'show_comments?',
      *actions_list(:index, :search, :new, :create, :seeking_clients, :terminate))
    refute_permit(volunteer_two.user, Volunteer,
      'superadmin_privileges?', 'show_acceptance?', 'show_comments?',
      *actions_list(:index, :search, :new, :create, :seeking_clients, :terminate))
  end
end
