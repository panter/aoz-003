require 'test_helper'

class JournalPolicyTest < PolicyAssertions::Test
  attr_reader :superadmin, :social_worker, :department_manager, :journal

  def setup
    @superadmin = create :user, role: 'superadmin'
    @social_worker = create :user, role: 'social_worker'
    @department_manager = create :user, role: 'department_manager'
    @journal = create :journal, user: @superadmin
  end

  test 'superadmin gets actions granted' do
    assert_permit(
      superadmin, journal,
      'new?', 'create?', 'index?', 'edit?', 'update?', 'destroy?'
    )
  end

  test 'socialworker or department_manager get no access' do
    refute_permit(
      social_worker, journal,
      'new?', 'create?', 'index?', 'edit?', 'update?', 'destroy?'
    )
    refute_permit(
      department_manager, journal,
      'new?', 'create?', 'index?', 'edit?', 'update?', 'destroy?'
    )
  end
end
