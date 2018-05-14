require 'test_helper'

class ClientPolicyTest < PolicyAssertions::Test
  def setup
    @superadmin = create :user
    @superadmin_client = create :client, user: @superadmin
    @social_worker = create :social_worker
    @social_client = create :client, user: @social_worker
    @social_involved = create :client, involved_authority: @social_worker,
      user: @superadmin
    @department_manager = create :department_manager
    @manager_client = create :client, user: @department_manager
  end

  test 'superadmin_can_use_all_actions' do
    assert_permit(@superadmin, Client,
      'superadmin_privileges?', 'show_comments?', *actions_list)
  end

  test 'department_manager_has_limited_access' do
    assert_permit(@department_manager, @manager_client,
      *actions_list(:edit, :update, :set_terminated), 'show_comments?')
    assert_permit(@department_manager, Client,
      *actions_list(:index, :search, :new, :create, :show), 'show_comments?')
    refute_permit(@department_manager, create(:client),
      *actions_list(:edit, :update, :set_terminated))
    refute_permit(@department_manager, Client, 'superadmin_privileges?',
      *actions_list(:set_terminated))
  end

  test 'social_worker_has_limited_access' do
    assert_permit(@social_worker, Client,
      *actions_list(:index, :search, :new, :create, :show), 'show_comments?')
    assert_permit(@social_worker, @social_client, *actions_list(:edit, :update), 'show_comments?')
    assert_permit(@social_worker, @social_involved, *actions_list(:edit, :update), 'show_comments?')
    refute_permit(@social_worker, create(:client), *actions_list(:edit, :update, :set_terminated))
    refute_permit(@social_worker, Client, 'superadmin_privileges?', *actions_list(:set_terminated))
  end

  test 'superadmin_scopes_all_clients' do
    result = Pundit.policy_scope!(@superadmin, Client)
    Client.all.each do |client|
      assert_includes result, client
    end
  end

  test 'social_worker_scopes_only_owned_or_competent_authority_clients' do
    result = Pundit.policy_scope!(@social_worker, Client)
    assert_includes result, @social_client
    assert_includes result, @social_involved
    refute_includes result, @superadmin_client
    refute_includes result, @manager_client
  end

  test 'department_manager_scopes_only_owned_clients' do
    result = Pundit.policy_scope!(@department_manager, Client)
    refute_includes result, @social_client
    refute_includes result, @social_involved
    refute_includes result, @superadmin_client
    assert_includes result, @manager_client
  end
end
