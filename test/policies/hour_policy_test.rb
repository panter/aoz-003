require 'test_helper'

class HourPolicyTest < PolicyAssertions::Test
  def setup
    @superadmin = create :user, role: 'superadmin'
    @social_worker = create :user, role: 'social_worker'
    @department_manager = create :user, role: 'department_manager'
    create :hour
  end

  test 'Create: Superadmin, social worker and department manager cannot create' do
    refute_permit @superadmin, Hour, 'new?', 'create?'
    refute_permit @social_worker, Hour, 'new?', 'create?'
    refute_permit @department_manager, Hour, 'new?', 'create?'
  end

  test 'Destroy: Superadmin, social worker and department manager cannot destroy' do
    refute_permit @superadmin, Hour.first, 'destroy?'
    refute_permit @social_worker, Hour.first, 'destroy?'
    refute_permit @department_manager, Hour.first, 'destroy?'
  end

  test 'Update: Superadmin, social worker and department manager cannot update' do
    refute_permit @superadmin, Hour.first, 'update?', 'edit?'
    refute_permit @social_worker, Hour.first, 'update?', 'edit?'
    refute_permit @department_manager, Hour.first, 'update?', 'edit?'
  end

  test 'Show: social worker and department manager cannot show' do
    refute_permit @social_worker, Hour.first, 'show?'
    refute_permit @department_manager, Hour.first, 'show?'
  end

  test 'Show: superadmin can see all hours' do
    create :hour
    Hour.all.each do |hour|
      assert_permit @superadmin, hour, 'show?'
    end
  end

  test 'Index: superadmin can index hours' do
    assert_permit @superadmin, Hour, 'index?'
  end

  test 'Index: social worker and department manager cannot index assignments' do
    refute_permit @social_worker, Hour, 'index?'
    refute_permit @department_manager, Hour, 'index?'
  end
end
