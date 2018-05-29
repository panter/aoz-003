require 'test_helper'

class GroupOfferPolicyTest < PolicyAssertions::Test
  test 'superadmin_can_use_all_actions' do
    assert_permit(create(:user), GroupOffer,
      *actions_list(except: [:change_active_state]), 'show_comments?')
  end

  test 'social_worker_has_no_access' do
    refute_permit(create(:social_worker), GroupOffer, *actions_list, 'show_comments?')
  end

  test 'department_manager_has_limited_access_when_set_as_responsible' do
    department_manager_without_department = create :department_manager_without_department
    manager_group_offer = create :group_offer, creator: department_manager_without_department
    other_group_offer = create :group_offer
    assert_permit(department_manager_without_department, GroupOffer,
      *actions_list(:index, :search, :new, :create), 'show_comments?')
    assert_permit(department_manager_without_department, manager_group_offer,
      *actions_list(:show, :edit, :update, :search_volunteer), 'show_comments?')
    assert_permit(department_manager_without_department, manager_group_offer,
      *actions_list(:show, :edit, :update, :search_volunteer), 'show_comments?')
    assert_permit(department_manager_without_department, other_group_offer,
      *actions_list(:index, :search, :show))
    refute_permit(department_manager_without_department, other_group_offer,
      *actions_list(:edit, :update, :search_volunteer))
    refute_permit(department_manager_without_department, GroupOffer, 'supervisor_privileges?')
  end

  test 'department_manager_has_limited_access_when_they_have_department' do
    department_manager = create :department_manager
    department_group_offer = create :group_offer, department: department_manager.department.last
    other_group_offer = create :group_offer

    assert_permit(department_manager, GroupOffer,
      *actions_list(:index, :search, :new, :create), 'show_comments?')
    assert_permit(department_manager, other_group_offer,
      *actions_list(:index, :search, :show))
    refute_permit(department_manager, other_group_offer,
      *actions_list(:edit, :update, :search_volunteer))
    refute_permit(department_manager, GroupOffer, 'supervisor_privileges?')
  end

  test 'volunteer_has_limited_access_when_in_group_offer' do
    volunteer = create :volunteer
    group_offer_volunteer = create :group_offer
    create(:group_assignment, volunteer: volunteer, group_offer: group_offer_volunteer)
    group_offer_other = create :group_offer
    refute_permit(volunteer.user, GroupOffer, *actions_list(except: [:show, :search_volunteer]),
      'supervisor_privileges?', 'show_comments?')
    assert_permit(volunteer.user, group_offer_volunteer, *actions_list(:show, :search_volunteer))
    refute_permit(volunteer.user, group_offer_other, *actions_list, 'show_comments?')
  end
end
