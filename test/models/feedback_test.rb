require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase
  test 'feedback is valid' do
    feedback = build :feedback
    assert feedback.valid?
  end

  test 'feedback with no comments is invalid' do
    volunteer = create :volunteer, user: create(:user_volunteer)
    invalid_feedback = Feedback.new(volunteer: volunteer, author: volunteer.user)
    refute invalid_feedback.valid?
    assert_equal ["can't be blank"], invalid_feedback.errors.messages[:comments]
  end
end
