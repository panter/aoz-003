require 'test_helper'

class GroupOffersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @superadmin = create :user
    @department_manager = create :department_manager
    @other_department_manager = create :department_manager
    @department = @department_manager.department.last
    @other_department = create :department
    @group_offer = create :group_offer, department: @department
  end

  test "superadmin can change the department of a group_offer" do
    params = { group_offer: { department_id: @other_department.id } }

    login_as @superadmin
    put group_offer_path(@group_offer), params: params

    assert_redirected_to edit_group_offer_path(@group_offer)
    assert_equal @group_offer.reload.department, @other_department
  end

  test "department_manager can change the department of a group_offer in her department" do
    params = { group_offer: { department_id: @other_department.id } }

    login_as @department_manager
    put group_offer_path(@group_offer), params: params

    assert_equal @group_offer.reload.department, @other_department
    assert_redirected_to group_offer_path(@group_offer)
  end

  test "department_manager from a different department can't change the department of a group_offer" do
    params = { group_offer: { department_id: @other_department.id } }

    login_as @other_department_manager
    put group_offer_path(@group_offer), params: params

    assert_redirected_to root_path
    refute_equal @group_offer.reload.department, @other_department
  end
end
