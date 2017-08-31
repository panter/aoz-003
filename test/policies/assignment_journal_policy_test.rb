require 'test_helper'

class AssignmentJournalPolicyTest < PolicyAssertions::Test
  def setup
    @superadmin = create :user, role: 'superadmin'
    @social_worker = create :user, role: 'social_worker'
    @department_manager = create :user, role: 'department_manager'
    create :assignment_journal
  end

  test 'Create: Only superadmin can create Assignment Journal' do
    assert_permit @superadmin, AssignmentJournal, 'new?', 'create?'
    refute_permit @social_worker, AssignmentJournal, 'new?', 'create?'
    refute_permit @department_manager, AssignmentJournal, 'new?', 'create?'
  end

  test 'Destroy: Only superadmin can destroy Assignment Journal' do
    assert_permit @superadmin, AssignmentJournal.first, 'destroy?'
    refute_permit @social_worker, AssignmentJournal.first, 'destroy?'
    refute_permit @department_manager, AssignmentJournal.first, 'destroy?'
  end

  test 'Update: Only superadmin can update Assignment Journal' do
    assert_permit @superadmin, AssignmentJournal.first, 'update?', 'edit?'
    refute_permit @social_worker, AssignmentJournal.first, 'update?', 'edit?'
    refute_permit @department_manager, AssignmentJournal.first, 'update?', 'edit?'
  end

  test 'Show: social worker and department manager cannot show Assignment Journal' do
    refute_permit @social_worker, AssignmentJournal.first, 'show?'
    refute_permit @department_manager, AssignmentJournal.first, 'show?'
  end

  test 'Show: superadmin can see all Assignment Journals' do
    create :assignment_journal
    AssignmentJournal.all.each do |assignment_journal|
      assert_permit @superadmin, assignment_journal, 'show?'
    end
  end

  test 'Index: Only superadmin can index Assignment Journals' do
    assert_permit @superadmin, AssignmentJournal, 'index?'
    refute_permit @social_worker, AssignmentJournal, 'index?'
    refute_permit @department_manager, AssignmentJournal, 'index?'
  end
end
