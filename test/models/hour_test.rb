require 'test_helper'

class HourTest < ActiveSupport::TestCase
  test 'hour can only be valid with hourable relation' do
    assignment = create :assignment, volunteer: create(:volunteer_with_user)
    hour = Hour.new(volunteer: assignment.volunteer, hours: 1, minutes: 0, meeting_date: 10.days.ago)
    refute hour.valid?
    assert_equal ['darf nicht leer sein'], hour.errors.messages[:hourable]
    hour.hourable = assignment
    assert hour.valid?
  end
end
