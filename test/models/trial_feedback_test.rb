require 'test_helper'

class TrialFeedbackTest < ActiveSupport::TestCase
  test 'trial feedback with no body is invalid' do
    volunteer = create :volunteer_with_user
    invalid_feedback = TrialFeedback.new(volunteer: volunteer, author: volunteer.user)
    refute invalid_feedback.valid?
    assert_equal ["can't be blank"], invalid_feedback.errors.messages[:body]
  end
end
