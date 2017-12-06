require 'test_helper'

class ReminderMailingPolicyTest < PolicyAssertions::Test
  test 'only superadmin is permitted to all actions' do
    actions = ['index?', 'new_half_year?', 'new_probation_period?', 'show?', 'send_probation?',
               'send_half_year?', 'create?', 'edit?', 'update?', 'destroy?']
    assert_permit(create(:user), ReminderMailing, *actions)

    refute_permit(create(:social_worker), ReminderMailing, *actions)
    refute_permit(create(:department_manager), ReminderMailing, *actions)
    refute_permit(create(:user_volunteer), ReminderMailing, *actions)
  end
end
