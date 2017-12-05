require 'test_helper'

class ListResponsesControllerTest < ActionDispatch::IntegrationTest
  test "should get feedbacks" do
    get list_responses_feedbacks_url
    assert_response :success
  end

  test "should get hours" do
    get list_responses_hours_url
    assert_response :success
  end

end
