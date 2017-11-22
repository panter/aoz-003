require 'test_helper'

class EmailTemplatePolicyTest < PolicyAssertions::Test
  attr_reader :superadmin, :social_worker, :department_manager, :email_template

  def setup
    @superadmin = create :user, role: 'superadmin'
    @social_worker = create :user, role: 'social_worker'
    @department_manager = create :user, role: 'department_manager'
    @email_template = create :email_template
  end

  test 'superadmin gets actions granted' do
    assert_permit(
      superadmin, email_template,
      'index?', 'show?', 'edit?', 'create?', 'update?', 'destroy?'
    )
  end

  test 'socialworker or department_manager get no access' do
    refute_permit(
      social_worker, email_template,
      'index?', 'show?', 'edit?', 'create?', 'update?', 'destroy?'
    )
    refute_permit(
      department_manager, email_template,
      'index?', 'show?', 'edit?', 'create?', 'update?', 'destroy?'
    )
  end
end
