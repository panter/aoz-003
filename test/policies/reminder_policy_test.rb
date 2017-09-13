require 'test_helper'

class ReminderPolicyTest < PolicyAssertions::Test
  test 'superadmin can only index, update, destroy' do
    assert_permit(create(:user), Reminder, 'index?', 'update?', 'destroy?')
    refute_permit(create(:user), Reminder, 'new?', 'create?', 'edit?')
  end

  test 'others have no access' do
    refute_permit(create(:social_worker), Reminder, 'new?', 'create?', 'index?', 'edit?',
      'update?', 'destroy?')
    refute_permit(create(:department_manager), Reminder, 'new?', 'create?', 'index?', 'edit?',
      'update?', 'destroy?')
    refute_permit(create(:user_volunteer), Reminder, 'new?', 'create?', 'index?', 'edit?',
      'update?', 'destroy?')
  end
end
