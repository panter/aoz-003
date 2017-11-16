require 'test_helper'

class BillingExpensePolicyTest < PolicyAssertions::Test
  def setup
    @superadmin = create :user, role: 'superadmin'
    @social_worker = create :user, role: 'social_worker'
    @department_manager = create :user, role: 'department_manager'
    @volunteer = create :volunteer_with_user
    @assignment = create(:assignment, volunteer: @volunteer,
      hours: [create(:hour, volunteer: @volunteer)])
    @billing_expense = BillingExpense.create!(user: @superadmin, volunteer: @volunteer, hours: @volunteer.hours.billable)
  end

  test 'Create: Only superadmin can create billing expense' do
    assert_permit @superadmin, BillingExpense, 'new?', 'create?'
    refute_permit @social_worker, BillingExpense, 'new?', 'create?'
    refute_permit @department_manager, BillingExpense, 'new?', 'create?'
  end

  test 'Destroy: Only superadmin can destroy billing expense' do
    assert_permit @superadmin, BillingExpense.first, 'destroy?'
    refute_permit @social_worker, BillingExpense.first, 'destroy?'
    refute_permit @department_manager, BillingExpense.first, 'destroy?'
  end

  test 'Update: Only superadmin can update billing expense' do
    assert_permit @superadmin, BillingExpense.first, 'update?', 'edit?'
    refute_permit @social_worker, BillingExpense.first, 'update?', 'edit?'
    refute_permit @department_manager, BillingExpense.first, 'update?', 'edit?'
  end

  test 'Show: social worker and department manager cannot show billing expenses' do
    refute_permit @social_worker, BillingExpense.first, 'show?'
    refute_permit @department_manager, BillingExpense.first, 'show?'
  end

  test 'Show: superadmin can see all billing expenses' do
    BillingExpense.create!(
      user: @superadmin, volunteer: @volunteer,
      hours: [
        create(:hour, volunteer: @volunteer, hourable: @assignment)
      ]
    )
    BillingExpense.all.each do |billing_expense|
      assert_permit @superadmin, billing_expense, 'show?'
    end
  end

  test 'Index: Only superadmin can index billing expenses' do
    assert_permit @superadmin, BillingExpense, 'index?'
    refute_permit @social_worker, BillingExpense, 'index?'
    refute_permit @department_manager, BillingExpense, 'index?'
  end
end
