require 'test_helper'

class ClientPolicyTest < PolicyAssertions::Test
  def setup
    @actions = ['index?', 'search?', 'new?', 'create?', 'show?', 'edit?', 'update?', 'termination?',
                'destroy?', 'superadmin_privileges?']
  end

  test 'superadmin_can_use_all_actions' do
    assert_permit(create(:user), Client, *@actions)
  end

  test 'department_manager_has_limited_access' do
    department_manager = create :department_manager, :with_clients
    assert_permit(department_manager, Client, *@actions[0..4])
    assert_permit(department_manager, Client.first, *@actions[5..7])
    refute_permit(department_manager, create(:client), *@actions[5..7])
    refute_permit(department_manager, Client, *@actions[-2..-1])
  end

  test 'social_worker_has_limited_access' do
    social_worker = create :social_worker, :with_clients
    assert_permit(social_worker, Client, *@actions[0..4])
    assert_permit(social_worker, Client.first, *@actions[5..6])
    refute_permit(social_worker, create(:client), *@actions[5..6])
    refute_permit(social_worker, Client, *@actions[-3..-1])
  end
end
