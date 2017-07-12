require 'test_helper'

class AssignmentPolicyTest < PolicyAssertions::Test
  def setup
    @superadmin = create :user, role: 'superadmin'
    @social_worker = create :user, role: 'social_worker'
    @department_manager = create :user, role: 'department_manager'
    @assignment = create :assignment
  end

  test 'Create: superadmin can create' do
    assert_permit @superadmin, Assignment, 'new?', 'create?'
  end

  test 'Create: social worker cannnot create' do
    refute_permit @social_worker, Assignment, 'new?', 'create?'
  end

  test 'Create: department manager cannot create' do
    refute_permit @department_manager, Assignment, 'new?', 'create?'
  end

  test 'Destroy: superadmin can destroy' do
    assert_permit @superadmin, Assignment.first, 'destroy?'
  end

  test 'Destroy: social worker cannot destroy' do
    refute_permit @social_worker, Assignment.first, 'destroy?'
  end

  test 'Destroy: department manager cannot destroy' do
    refute_permit @department_manager, Assignment.first, 'destroy?'
  end

  test 'Update: superadmin can update assignment' do
    assert_permit @superadmin, Assignment.first, 'update?', 'edit?'
  end

  test 'Update: social worker cannot update assignment' do
    refute_permit @social_worker, Assignment.first, 'update?', 'edit?'
  end

  test 'Update: department manager cannot update assignment' do
    refute_permit @department_manager, Assignment.first, 'update?', 'edit?'
  end

  test 'Show: social worker cannot show assignment' do
    refute_permit @social_worker, Assignment.first, 'show?'
  end

  test 'Show: department manager cannot show assignment' do
    refute_permit @department_manager, Assignment.first, 'show?'
  end

  test 'Show: superadmin can see all assignments' do
    Assignment.all.each do |assignment|
      assert_permit @superadmin, assignment, 'show?'
    end
  end

  test 'Index: superadmin can index assignments' do
    assert_permit @superadmin, Assignment.first, 'index?'
  end

  test 'Index: social worker cannot index assignments' do
    refute_permit @social_worker, Assignment.first, 'index?'
  end

  test 'Index: department manager cannot index assignments' do
    refute_permit @department_manager, Assignment.first, 'index?'
  end

  test 'Find volunteer: superadmin can find a volunteer for client' do
    assert_permit @superadmin, Assignment.first, 'find_volunteer?'
  end

  test 'Find volunteer: social worker cannot find a volunteer for client' do
    refute_permit @social_worker, Assignment.first, 'find_volunteer?'
  end

  test 'Find volunteer: department_manager cannot find a volunteer for client' do
    refute_permit @department_manager, Assignment.first, 'find_volunteer?'
  end

  test 'Find client: superadmin can find a client for volunteer' do
    assert_permit @superadmin, Assignment.first, 'find_client?'
  end

  test 'Find client: social worker cannot find a client for volunteer' do
    refute_permit @social_worker, Assignment.first, 'find_client?'
  end

  test 'Find client: department_manager cannot find a client for volunteer' do
    refute_permit @department_manager, Assignment.first, 'find_client?'
  end
end
