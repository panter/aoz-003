require 'test_helper'

class AssignmentJournalPolicyTest < PolicyAssertions::Test
  test 'superadmin can use all actions' do
    assert_permit(create(:user), AssignmentJournal, 'new?', 'create?', 'index?', 'show?', 'edit?',
      'update?', 'destroy?')
  end

  test 'social worker and department manager have no access' do
    refute_permit(create(:social_worker), AssignmentJournal, 'new?', 'create?', 'index?', 'show?',
      'edit?', 'update?', 'destroy?')
    refute_permit(create(:department_manager), AssignmentJournal, 'new?', 'create?', 'index?',
      'show?', 'edit?', 'update?', 'destroy?')
  end

  test 'volunteer has limited access' do
    volunteer = create(:user_volunteer)
    assignment_journal = create :assignment_journal
    assignment_journal_volunteer = create :assignment_journal, author: volunteer
    refute_permit(volunteer, assignment_journal, 'show?', 'edit?', 'update?', 'destroy?')
    assert_permit(volunteer, assignment_journal_volunteer, 'index?', 'show?', 'edit?', 'update?',
      'destroy?')
  end
end
