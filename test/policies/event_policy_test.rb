require 'test_helper'

class EventPolicyTest < PolicyAssertions::Test
  test 'superadmin_can_use_all_actions' do
    assert_permit(create(:user), Event, *actions_list)
  end

  test 'department_manager_has_no_access' do
    refute_permit(create(:department_manager, :with_clients), Event, *actions_list)
  end

  test 'social_worker_has_no_access' do
    refute_permit(create(:social_worker, :with_clients), Event, *actions_list)
  end
end
