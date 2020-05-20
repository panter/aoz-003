require 'test_helper'

class CertificatePolicyTest < PolicyAssertions::Test
  test 'superadmin can use all actions' do
    assert_permit(create(:user), Certificate, 'new?', 'create?', 'index?', 'show?', 'edit?',
                  'update?', 'destroy?')
  end

  test 'others have no access' do
    refute_permit(create(:social_worker), Certificate, 'new?', 'create?', 'index?', 'show?',
                  'edit?',
                  'update?', 'destroy?')
    refute_permit(create(:department_manager), Certificate, 'new?', 'create?', 'index?', 'show?',
                  'edit?',
                  'update?', 'destroy?')
    refute_permit(create(:user_volunteer), Certificate, 'new?', 'create?', 'index?', 'show?',
                  'edit?',
                  'update?', 'destroy?')
  end
end
