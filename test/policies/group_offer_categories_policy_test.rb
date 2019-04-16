require 'test_helper'

class GroupOfferCategoryPolicyTest < PolicyAssertions::Test
  test 'superadmin can use all category actions' do
    assert_permit(create(:user), GroupOfferCategory, 'new?', 'create?', 'index?', 'show?', 'edit?',
      'update?')
  end

  test 'department managaer can show and index' do
    department_manager = create(:department_manager)
    assert_permit(department_manager, GroupOfferCategory, 'index?', 'show?')
    refute_permit(department_manager, GroupOfferCategory, 'new?', 'create?', 'edit?', 'update?')
  end

  test 'social_worker cant use categories' do
    social_worker = create(:social_worker)
    refute_permit(social_worker, GroupOfferCategory, 'index?', 'show?', 'new?', 'create?', 'edit?',
      'update?')
  end
end
