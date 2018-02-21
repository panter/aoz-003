require 'test_helper'

class EventVolunteerPolicyTest < PolicyAssertions::Test
  test 'superadmin_can_use_all_actions' do
    assert_permit(create(:user), EventVolunteer, *actions_list(:create, :destroy))
  end

  test 'department_manager_has_no_access' do
    refute_permit(create(:department_manager, :with_clients), EventVolunteer, *actions_list(:create, :destroy))
  end

  test 'social_worker_has_no_access' do
    refute_permit(create(:social_worker, :with_clients), EventVolunteer, *actions_list(:create, :destroy))
  end
end
