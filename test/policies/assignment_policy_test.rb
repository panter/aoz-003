require 'test_helper'

class AssignmentPolicyTest < PolicyAssertions::Test
  def setup
    @superadmin = create :user, role: 'superadmin'
    @social_worker = create :user, role: 'social_worker'
    @department_manager = create :department_manager
    @assignment = create :assignment
  end

  test 'Create: superadmin can create' do
    assert_permit @superadmin, Assignment, 'new?', 'create?'
  end

  test 'Create: social worker cannnot create' do
    refute_permit @social_worker, Assignment, 'new?', 'create?'
  end

  test 'Create: department manager can create' do
    assert_permit @department_manager, Assignment, 'new?', 'create?'
  end

  test 'Destroy: superadmin can destroy' do
    assert_permit @superadmin, @assignment, 'destroy?'
  end

  test 'Destroy: social worker cannot destroy' do
    refute_permit @social_worker, @assignment, 'destroy?'
  end

  test 'Destroy: department manager cannot destroy' do
    refute_permit @department_manager, @assignment, 'destroy?'
  end

  test 'Update: superadmin can update assignment' do
    assert_permit @superadmin, @assignment, 'update?', 'edit?'
  end

  test 'Update: social worker cannot update assignment' do
    refute_permit @social_worker, @assignment, 'update?', 'edit?'
  end

  test 'Update: department manager can update assignment' do
    assert_permit @department_manager, @assignment, 'update?', 'edit?'
  end

  test 'Show: social worker cannot show assignment' do
    refute_permit @social_worker, @assignment, 'show?', 'last_submitted_hours_and_feedbacks?'
  end

  test 'Show: department manager can show assignment' do
    assert_permit @department_manager, @assignment, 'show?', 'last_submitted_hours_and_feedbacks?'
  end

  test 'Show: superadmin can see all assignments' do
    Assignment.all.each do |assignment|
      assert_permit @superadmin, assignment, 'show?'
    end
  end

  test 'Index: superadmin can index assignments' do
    assert_permit @superadmin, @assignment, 'index?'
  end

  test 'Index: social worker cannot index assignments' do
    refute_permit @social_worker, @assignment, 'index?'
  end

  test 'Index: department manager can index assignments' do
    assert_permit @department_manager, @assignment, 'index?'
  end

  test 'Find volunteer: superadmin can find a volunteer for client' do
    assert_permit @superadmin, @assignment, 'find_volunteer?'
  end

  test 'Find volunteer: social worker cannot find a volunteer for client' do
    refute_permit @social_worker, @assignment, 'find_volunteer?'
  end

  test 'Find volunteer: department_manager can find a volunteer for client' do
    assert_permit @department_manager, @assignment, 'find_volunteer?'
  end

  test 'Find client: superadmin can find a client for volunteer' do
    assert_permit @superadmin, @assignment, 'find_client?'
  end

  test 'Find client: social worker cannot find a client for volunteer' do
    refute_permit @social_worker, @assignment, 'find_client?'
  end

  test 'Find client: department_manager can find a client for volunteer' do
    assert_permit @department_manager, @assignment, 'find_client?'
  end
end
