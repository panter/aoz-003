require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase
  test 'feedback with no comments is invalid' do
    volunteer = create :volunteer_with_user
    invalid_feedback = Feedback.new(volunteer: volunteer, author: volunteer.user)
    refute invalid_feedback.valid?
    assert_equal ["can't be blank"], invalid_feedback.errors.messages[:comments]
  end
end
