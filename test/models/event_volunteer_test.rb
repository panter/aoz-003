require 'test_helper'

class EventVolunteerTest < ActiveSupport::TestCase
  def setup
    @volunteer = create :volunteer_with_user, intro_course: false
    @event = create :event, kind: :intro_course

    @event_volunteer = create :event_volunteer, volunteer: @volunteer, event: @event, creator: create(:user)
  end

  test 'adding volunteer to event marks intro course true' do
    assert @event_volunteer.volunteer.intro_course
  end

  test 'adding volunteer to event marks intro course false' do
    @event_volunteer.destroy
    refute @event_volunteer.volunteer.intro_course
  end

  test 'adding same volunteer twice to an event does not work' do
    event_volunteer = build :event_volunteer, volunteer: @volunteer, event: @event, creator: create(:user)

    refute event_volunteer.valid?
    assert_equal ["Freiwillige/r ist bereits in dieser Veranstaltung."], event_volunteer.errors.full_messages_for(:volunteer_id)
  end

  test 'presence validations' do
    event_volunteer = build :event_volunteer, volunteer: nil, event: nil, creator: nil

    refute event_volunteer.valid?
    assert_equal [:event, :volunteer, :creator], event_volunteer.errors.keys
  end
end
