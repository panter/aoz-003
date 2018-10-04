require 'test_helper'

class SemesterProcessesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @semester_process = semester_processes(:one)
  end

  test "should get index" do
    get semester_processes_url
    assert_response :success
  end

  test "should get new" do
    get new_semester_process_url
    assert_response :success
  end

  test "should create semester_process" do
    assert_difference('SemesterProcess.count') do
      post semester_processes_url, params: { semester_process: { semester_end: @semester_process.semester_end, semester_start: @semester_process.semester_start, user_id: @semester_process.user_id } }
    end

    assert_redirected_to semester_process_url(SemesterProcess.last)
  end

  test "should show semester_process" do
    get semester_process_url(@semester_process)
    assert_response :success
  end

  test "should get edit" do
    get edit_semester_process_url(@semester_process)
    assert_response :success
  end

  test "should update semester_process" do
    patch semester_process_url(@semester_process), params: { semester_process: { semester_end: @semester_process.semester_end, semester_start: @semester_process.semester_start, user_id: @semester_process.user_id } }
    assert_redirected_to semester_process_url(@semester_process)
  end

  test "should destroy semester_process" do
    assert_difference('SemesterProcess.count', -1) do
      delete semester_process_url(@semester_process)
    end

    assert_redirected_to semester_processes_url
  end
end
