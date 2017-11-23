require 'test_helper'

class VolunteerEmailPolicyTest < PolicyAssertions::Test
  attr_reader :superadmin, :social_worker, :manual

  def setup
    @superadmin = create :user, role: 'superadmin'
    @social_worker = create :user, role: 'social_worker'
    @manual = create :manual, user: @superadmin
  end

  test 'superadmin gets actions granted' do
    assert_permit(
      superadmin, manual,
      'index?', 'edit?', 'create?', 'update?', 'destroy?'
    )
  end

  test 'socialworker gets no access' do
    refute_permit(
      social_worker, manual,
      'index?', 'edit?', 'create?', 'update?', 'destroy?'
    )
  end
end
