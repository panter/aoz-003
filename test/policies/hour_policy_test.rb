require 'test_helper'

class HourPolicyTest < PolicyAssertions::Test
  def setup
    @superadmin = create :user, role: 'superadmin'
    @social_worker = create :user, role: 'social_worker'
    @department_manager = create :department_manager
    create :hour
  end

  test 'Create: Only superadmin can create' do
    assert_permit @superadmin, Hour, 'new?', 'create?'
    refute_permit @social_worker, Hour, 'new?', 'create?'
    refute_permit @department_manager, Hour, 'new?', 'create?'
  end

  test 'Destroy: Only superadmin can destroy' do
    assert_permit @superadmin, Hour.first, 'destroy?'
    refute_permit @social_worker, Hour.first, 'destroy?'
    refute_permit @department_manager, Hour.first, 'destroy?'
  end

  test 'Update: Only superadmin can update' do
    assert_permit @superadmin, Hour.first, 'update?', 'edit?'
    refute_permit @social_worker, Hour.first, 'update?', 'edit?'
    refute_permit @department_manager, Hour.first, 'update?', 'edit?'
  end

  test 'Show: social worker cannot show' do
    refute_permit @social_worker, Hour.first, 'show?'
    assert_permit @department_manager, Hour.first, 'show?'
  end

  test 'Show: superadmin can see all hours' do
    create :hour
    Hour.all.each do |hour|
      assert_permit @superadmin, hour, 'show?'
    end
  end

  test 'Index: Only superadmin and department manager can index hours' do
    assert_permit @superadmin, Hour, 'index?'
    refute_permit @social_worker, Hour, 'index?'
    assert_permit @department_manager, Hour, 'index?'
  end
end
