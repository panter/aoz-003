require 'test_helper'

class GroupOfferPolicyTest < PolicyAssertions::Test
  test 'superadmin_can_use_all_actions' do
    assert_permit(create(:user), GroupOffer,
      *actions_list(except: [:change_active_state]), 'show_comments?')
  end

  test 'social_worker_has_no_access' do
    refute_permit(create(:social_worker), GroupOffer, *actions_list, 'show_comments?')
  end

  test 'department_manager without departments have read-only access' do
    department_manager_without_department = create :department_manager_without_department
    manager_group_offer = create :group_offer, creator: department_manager_without_department
    other_group_offer = create :group_offer

    assert_permit(department_manager_without_department, GroupOffer, index_actions)

    refute_permit(department_manager_without_department, GroupOffer, new_actions)

    assert_permit(department_manager_without_department, manager_group_offer, show_actions)
    assert_permit(department_manager_without_department, other_group_offer, show_actions)

    refute_permit(department_manager_without_department, manager_group_offer,
      *edit_actions, 'show_comments?')
    refute_permit(department_manager_without_department, other_group_offer,
      *edit_actions, 'show_comments?')

    refute_permit(department_manager_without_department, GroupOffer, 'supervisor_privileges?')
  end

  test 'department_manager has full access in their departments but limited in others' do
    department_manager = create :department_manager
    department_group_offer = create :group_offer, department: department_manager.department.last
    other_group_offer = create :group_offer

    assert department_manager.department != department_group_offer.department

    assert_permit(department_manager, GroupOffer, index_actions)

    assert_permit(department_manager, GroupOffer, new_actions)

    assert_permit(department_manager, department_group_offer, show_actions, 'show_comments?')
    assert_permit(department_manager, other_group_offer, show_actions)

    assert_permit(department_manager, department_group_offer, *edit_actions, 'show_comments?')
    refute_permit(department_manager, other_group_offer, *edit_actions, 'show_comments?')

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

  private

  def index_actions
    actions_list(:index, :search)
  end

  def show_actions
    actions_list(:show)
  end

  def new_actions
    actions_list(:new, :create)
  end

  def edit_actions
    actions_list(
      :edit,
      :update,
      :change_active_state,
      :initiate_termination,
      :submit_initiate_termination,
      :end_all_assignments,
      :search_volunteer
    )
  end
end
