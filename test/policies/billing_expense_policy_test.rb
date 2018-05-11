require 'test_helper'

class BillingExpensePolicyTest < PolicyAssertions::Test
  def setup
    @superadmin = create :user, role: 'superadmin'
    @social_worker = create :user, role: 'social_worker'
    @department_manager = create :user, role: 'department_manager'

    @volunteer1 = create :volunteer_with_user
    @assignment1 = create(:assignment, volunteer: @volunteer1,
      hours: [create(:hour, volunteer: @volunteer1)])
    @billing_expense1 = create(:billing_expense,
      user: @superadmin,
      volunteer: @volunteer1,
      hours: @volunteer1.hours.billable)

    @volunteer2 = create :volunteer_with_user
    @assignment2 = create(:assignment, volunteer: @volunteer2,
      hours: [create(:hour, volunteer: @volunteer2)])
    @billing_expense2 = create(:billing_expense,
      user: @superadmin,
      volunteer: @volunteer2,
      hours: @volunteer2.hours.billable)
  end

  test 'superadmin can use all actions' do
    assert_permit(@superadmin, BillingExpense, 'superadmin_privileges?', *actions_list)
  end

  test 'department manager has no access' do
    refute_permit(@department_manager, BillingExpense, 'superadmin_privileges?', *actions_list)
  end

  test 'socialworker has no access' do
    refute_permit(@social_worker, BillingExpense, 'superadmin_privileges?', *actions_list)
  end

  test 'volunteer has only access to own index and show' do
    assert_permit(@volunteer1.user, BillingExpense,
      *actions_list(:index, :download))
    refute_permit(@volunteer1.user, BillingExpense,
      *actions_list(except: [:index, :download, :show]))

    # volunteer1's billing expense
    assert_permit(@volunteer1.user, @billing_expense1,
      *actions_list(:index, :show))
    refute_permit(@volunteer1.user, @billing_expense1,
      *actions_list(except: [:index, :download, :show]))

    refute_permit(@volunteer1.user, @billing_expense2,
      *actions_list(except: [:index, :download]))


    # volunteer2's billing expense
    assert_permit(@volunteer2.user, @billing_expense2,
      *actions_list(:index, :download, :show))
    refute_permit(@volunteer2.user, @billing_expense2,
      *actions_list(except: [:index, :download, :show]))

    refute_permit(@volunteer2.user, @billing_expense1,
      *actions_list(except: [:index, :download]))
  end

  test 'superadmin scopes all billing expenses' do
    result = Pundit.policy_scope!(@superadmin, BillingExpense)
    BillingExpense.all.each do |bill|
      assert_includes result, bill
    end
  end

  test 'social worker scopes nothing' do
    result = Pundit.policy_scope!(@social_worker, BillingExpense)
    refute_includes result, @billing_expense1
    refute_includes result, @billing_expense2
  end

  test 'department manager scopes nothing' do
    result = Pundit.policy_scope!(@department_manager, BillingExpense)
    refute_includes result, @billing_expense1
    refute_includes result, @billing_expense2
  end

  test 'volunteer scopes only own billing expenses' do
    result = Pundit.policy_scope!(@volunteer1.user, BillingExpense)
    assert_includes result, @billing_expense1
    refute_includes result, @billing_expense2
  end
end
