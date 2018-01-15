require 'test_helper'

class HourTest < ActiveSupport::TestCase
  test 'hour can only be valid with hourable relation' do
    assignment = create :assignment, volunteer: create(:volunteer_with_user)
    hour = Hour.new(volunteer: assignment.volunteer, hours: 1, minutes: 0, meeting_date: 10.days.ago)
    refute hour.valid?
    assert hour.errors.messages[:hourable].include? "can't be blank"
    hour.hourable = assignment
    assert hour.valid?
  end
end
