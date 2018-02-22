require 'test_helper'

class EventVolunteerTest < ActiveSupport::TestCase
  def setup
    @volunteer = create :volunteer_with_user, intro_course: false
    @event = create :event, kind: :intro_course

    @event_volunteer = EventVolunteer.create!(volunteer: @volunteer, event: @event, creator: create(:user))
  end

  test 'adding volunteer to event marks intro course true' do
    assert @event_volunteer.volunteer.intro_course
  end

  test 'adding volunteer to event marks intro course false' do
    @event_volunteer.destroy
    refute @event_volunteer.volunteer.intro_course
  end
end
