require 'test_helper'

class VolunteerEmailPolicyTest < PolicyAssertions::Test
  attr_reader :superadmin, :social_worker, :department_manager, :volunteer_email

  def setup
    @superadmin = create :user, role: 'superadmin'
    @social_worker = create :user, role: 'social_worker'
    @department_manager = create :user, role: 'department_manager'
    @volunteer_email = create :volunteer_email, user: @superadmin
  end

  test 'superadmin gets actions granted' do
    assert_permit(
      superadmin, volunteer_email,
      'index?', 'show?', 'edit?', 'create?', 'update?', 'destroy?', 'supervisor_privileges?'
    )
  end

  test 'socialworker or department_manager get no access' do
    refute_permit(
      social_worker, volunteer_email,
      'index?', 'show?', 'edit?', 'create?', 'update?', 'destroy?', 'supervisor_privileges?'
    )
    refute_permit(
      department_manager, volunteer_email,
      'index?', 'show?', 'edit?', 'create?', 'update?', 'destroy?', 'supervisor_privileges?'
    )
  end
end
