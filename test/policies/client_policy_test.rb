require 'test_helper'

class ClientPolicyTest < PolicyAssertions::Test
  test 'superadmin_can_use_all_actions' do
    assert_permit(create(:user), Client, 'superadmin_privileges?', *actions_list.values)
  end

  test 'department_manager_has_limited_access' do
    manager = create :department_manager, :with_clients
    assert_permit(manager, manager.clients.first, *actions_list(:edit, :update, :set_terminated))
    assert_permit(manager, Client, *actions_list(:index, :search, :new, :create, :show))
    refute_permit(manager, create(:client), *actions_list(:edit, :update, :set_terminated))
    refute_permit(manager, Client, 'superadmin_privileges?', *actions_list(:set_terminated))
  end

  test 'social_worker_has_limited_access' do
    social_worker = create :social_worker, :with_clients
    assert_permit(social_worker, Client, *actions_list(:index, :search, :new, :create, :show))
    assert_permit(social_worker, social_worker.clients.first, *actions_list(:edit, :update))
    refute_permit(social_worker, create(:client), *actions_list(:edit, :update, :set_terminated))
    refute_permit(social_worker, Client, 'superadmin_privileges?', *actions_list(:set_terminated))
  end
end
