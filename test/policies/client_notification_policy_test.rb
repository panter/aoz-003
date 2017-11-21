require 'test_helper'

class ClientNotificationPolicyTest < PolicyAssertions::Test
  attr_reader :superadmin, :social_worker, :client_notification

  def setup
    @superadmin = create :user, role: 'superadmin'
    @social_worker = create :user, role: 'social_worker'
    @client_notification = create :client_notification, user: @superadmin
  end

  test 'superadmin gets actions granted' do
    assert_permit(
      superadmin, client_notification,
      'index?', 'clients_index?', 'edit?', 'create?', 'update?', 'destroy?'
    )
  end

  test 'socialworker get no access' do
    refute_permit(
      social_worker, client_notification,
      'index?', 'clients_index?', 'edit?', 'create?', 'update?', 'destroy?'
    )
  end
end
