require 'test_helper'

class GroupOfferPolicyTest < PolicyAssertions::Test
  def setup
    @actions = ['index?', 'search?', 'new?', 'create?', 'show?', 'edit?', 'update?',
                'change_active_state?', 'destroy?', 'supervisor_privileges?']
  end

  test 'superadmin_can_use_all_actions' do
    assert_permit(create(:user), GroupOffer, *@actions)
  end

  test 'social_worker_has_no_access' do
    refute_permit(create(:social_worker), GroupOffer, *@actions)
  end

  test 'department_manager_has_limited_access_when_set_as_responsible' do
    department_manager_without_department = create :department_manager_without_department
    manager_group_offer = create :group_offer, creator: department_manager_without_department
    other_group_offer = create :group_offer
    refute_permit(department_manager_without_department, GroupOffer, 'destroy?',
      'supervisor_privileges?')
    assert_permit(department_manager_without_department, GroupOffer, 'index?', 'search?', 'new?',
      'create?')
    assert_permit(department_manager_without_department, manager_group_offer, 'show?',
      'edit?', 'update?', 'change_active_state?')
    refute_permit(department_manager_without_department, other_group_offer, 'show?', 'edit?',
      'update?', 'change_active_state?')
  end

  test 'department_manager_has_limited_access_when_they_have_department' do
    department_manager = create :department_manager
    department_group_offer = create :group_offer, department: department_manager.department.last
    other_group_offer = create :group_offer
    refute_permit(department_manager, GroupOffer, 'destroy?', 'supervisor_privileges?')
    assert_permit(department_manager, GroupOffer, 'index?', 'search?', 'new?', 'create?')
    assert_permit(department_manager, department_group_offer, 'show?', 'edit?', 'update?',
      'change_active_state?')
    refute_permit(department_manager, other_group_offer, 'show?', 'edit?', 'update?',
      'change_active_state?')
  end

  test 'volunteer_has_limited_access_when_in_group_offer' do
    volunteer = create :volunteer_with_user
    group_offer_volunteer = create :group_offer, volunteers: [volunteer]
    group_offer_other = create :group_offer
    refute_permit(volunteer.user, GroupOffer, 'search?', 'new?', 'create?', 'index?', 'edit?',
      'update?', 'destroy?', 'supervisor_privileges?', 'change_active_state?')
    assert_permit(volunteer.user, group_offer_volunteer, 'show?')
    refute_permit(volunteer.user, group_offer_other, 'show?')
  end
end
