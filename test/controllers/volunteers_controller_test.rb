require 'test_helper'

class VolunteersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @superadmin = create :user, role: 'superadmin'
    @department_manager = create :department_manager
    @volunteer = create :volunteer, registrar: @department_manager
    @department = create :department
  end

  test "superadmin can update department of volunteers" do
    params = { volunteer: { department_id: @department.id } }

    login_as @superadmin
    put volunteer_path(@volunteer), params: params

    assert_redirected_to edit_volunteer_path(@volunteer)
    assert_equal @volunteer.reload.department, @department
  end

  test "department_manager can't update department of volunteers" do
    params = { volunteer: { department_id: @department.id } }

    login_as @department_manager
    put volunteer_path(@volunteer), params: params

    assert_redirected_to edit_volunteer_path(@volunteer)
    refute_equal @volunteer.reload.department, @department
  end
end
