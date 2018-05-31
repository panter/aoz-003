require 'test_helper'

class GroupOffersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @department = create :department
    @other_department = create :department
    @group_offer = create :group_offer, department: @department
    @superadmin = create :user
    @department_manager = create :department_manager, department: [@department]
  end

  test "superadmin can change the department of a group_offer" do
    params = { group_offer: { department_id: @other_department.id } }

    login_as @superadmin
    put group_offer_path(@group_offer), params: params

    assert_redirected_to edit_group_offer_path(@group_offer)
    assert_equal @group_offer.reload.department, @other_department
  end

  test "non-superadmins should not change the department of a group_offer" do
    params = { group_offer: { department_id: @other_department.id } }

    login_as @department_manager
    put group_offer_path(@group_offer), params: params

    assert_redirected_to edit_group_offer_path(@group_offer)
    refute_equal @group_offer.reload.department, @other_department
  end
end
