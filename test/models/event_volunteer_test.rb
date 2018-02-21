require 'test_helper'

class EventVolunteerTest < ActiveSupport::TestCase

  test 'adding volunteer to event marks intro course true' do
    @volunteer = create :volunteer_with_user
    @event = create :event

    assert_equal false, @volunteer.intro_course
    @event_volunteer = EventVolunteer.create!(volunteer: @volunteer, event: @event)

    # FIXME:
    # assert_equal true, @event_volunteer.volunteer.intro_course
  end
end
