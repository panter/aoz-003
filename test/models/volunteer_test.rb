require 'test_helper'

class VolunteerTest < ActiveSupport::TestCase
  def setup
    @volunteer = create :volunteer
  end

  test 'valid factory' do
    assert @volunteer.valid?
  end

  test 'schedules build correctly automaticly' do
    new_volunteer = create :volunteer
    new_volunteer.valid? # to kick build_schedules in callback
    assert_equal new_volunteer.schedules.size, 21
  end

  test 'schedules size validaton checks for the right size' do
    new_volunteer = create :volunteer
    new_volunteer.valid?
    new_volunteer.schedules.push Schedule.new
    refute new_volunteer.valid?
    assert new_volunteer.errors.messages == { schedules: ['too many'] }
    new_volunteer.schedules.delete_all
    new_volunteer.schedules.push Schedule.new
    refute new_volunteer.valid?
    assert new_volunteer.errors.messages == { schedules: ['not enough'] }
  end

  test 'contact relation is build automaticly' do
    new_volunteer = Volunteer.new
    assert new_volunteer.contact.present?
  end

  test 'only accepted, active further and inactive volunteers should show up for assignment' do
    @accepted = create :volunteer, state: Volunteer::ACCEPTED
    @active_further = create :volunteer, state: Volunteer::ACTIVE_FURTHER
    @inactive = create :volunteer, state: Volunteer::INACTIVE
    @registered = create :volunteer, state: Volunteer::REGISTERED
    @contacted = create :volunteer, state: Volunteer::CONTACTED
    @active = create :volunteer, state: Volunteer::ACTIVE
    @rejected = create :volunteer, state: Volunteer::REJECTED
    @resigned = create :volunteer, state: Volunteer::RESIGNED
    result = Volunteer.seeking_clients
    assert_equal [@inactive, @active_further, @accepted], result.to_a
  end
end
