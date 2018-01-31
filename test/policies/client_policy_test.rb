require 'test_helper'

class ClientPolicyTest < PolicyAssertions::Test
  test 'superadmin_can_use_all_actions' do
    assert_permit(create(:user), Client,
      'index?', 'search?', 'new?', 'create?', 'show?', 'edit?', 'update?', 'termination?',
      'superadmin_privileges?', 'set_terminated?')
  end

  test 'department_manager_has_limited_access' do
    department_manager = create :department_manager, :with_clients
    assert_permit(department_manager, department_manager.clients.first,
      'edit?', 'update?', 'termination?', 'set_terminated?')
    assert_permit(department_manager, Client,
      'index?', 'search?', 'new?', 'create?', 'show?')
    refute_permit(department_manager, create(:client),
      'edit?', 'update?', 'termination?', 'set_terminated?')
    refute_permit(department_manager, Client,
      'superadmin_privileges?', 'set_terminated?')
  end

  test 'social_worker_has_limited_access' do
    social_worker = create :social_worker, :with_clients
    assert_permit(social_worker, Client,
      'index?', 'search?', 'new?', 'create?', 'show?')
    assert_permit(social_worker, social_worker.clients.first,
      'edit?', 'update?')
    refute_permit(social_worker, create(:client),
      'edit?', 'update?', 'set_terminated?')
    refute_permit(social_worker, Client,
      'termination?', 'superadmin_privileges?', 'set_terminated?')
  end
end
