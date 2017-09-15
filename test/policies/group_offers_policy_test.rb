require 'test_helper'

class GroupOfferPolicyTest < PolicyAssertions::Test
  test 'superadmin can use all actions' do
    assert_permit(create(:user), GroupOffer, 'new?', 'create?', 'index?', 'show?', 'edit?',
      'update?', 'destroy?')
  end

  test 'social worker and volunteer have no access' do
    refute_permit(create(:social_worker), GroupOffer, 'new?', 'create?', 'index?', 'show?',
      'edit?', 'update?', 'destroy?')
    refute_permit(create(:user_volunteer), GroupOffer, 'new?', 'create?', 'index?', 'show?',
      'edit?', 'update?', 'destroy?')
  end

  test 'department manager has limited access' do
    department_manager = create :department_manager, :with_departments
    create :group_offer
    create :group_offer, department: Department.last
    refute_permit(department_manager, GroupOffer, 'destroy?')
    assert_permit(department_manager, GroupOffer, 'new?', 'create?', 'index?')
    refute_permit(department_manager, GroupOffer.first, 'show?', 'edit?', 'update?')
    assert_permit(department_manager, GroupOffer.second, 'show?', 'edit?', 'update?')
  end
end
