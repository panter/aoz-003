require 'test_helper'

class GroupOfferPolicyTest < PolicyAssertions::Test
  test 'superadmin can use all actions' do
    assert_permit(create(:user), GroupOffer, 'new?', 'create?', 'index?', 'show?', 'edit?',
      'update?', 'destroy?')
  end

  test 'social worker has no access' do
    refute_permit(create(:social_worker), GroupOffer, 'new?', 'create?', 'index?', 'show?',
      'edit?', 'update?', 'destroy?')
  end

  test 'department manager has limited access' do
    department_manager = create :department_manager
    department_manager_offer = create :group_offer, department: department_manager.department.last
    other_group_offer = create :group_offer
    refute_permit(department_manager, GroupOffer, 'destroy?')
    assert_permit(department_manager, GroupOffer, 'new?', 'create?', 'index?')
    refute_permit(department_manager, other_group_offer, 'show?', 'edit?', 'update?')
    assert_permit(department_manager, department_manager_offer, 'show?', 'edit?', 'update?')
    refute_permit(department_manager, other_group_offer, 'show?', 'edit?', 'update?')
  end

  test 'volunteer has limited access' do
    volunteer = create :volunteer_with_user
    group_offer_volunteer = create :group_offer, volunteers: [volunteer]
    group_offer_other = create :group_offer
    refute_permit(volunteer.user, GroupOffer, 'new?', 'create?', 'index?',
      'edit?', 'update?', 'destroy?')
    assert_permit(volunteer.user, group_offer_volunteer, 'show?')
    refute_permit(volunteer.user, group_offer_other, 'show?')
  end
end
