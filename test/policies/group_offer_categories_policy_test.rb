require 'test_helper'

class GroupOfferCategoryPolicyTest < PolicyAssertions::Test
  test 'superadmin can use all category actions' do
    assert_permit(create(:user), GroupOfferCategory, 'new?', 'create?', 'index?', 'show?', 'edit?',
      'update?')
  end

  test 'department managaer can use all category actions' do
    assert_permit(create(:department_manager), GroupOfferCategory, 'new?', 'create?', 'index?',
      'show?', 'edit?', 'update?')
  end
end
