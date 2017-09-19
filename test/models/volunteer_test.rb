require 'test_helper'

class VolunteerTest < ActiveSupport::TestCase
  def setup
    @volunteer = create :volunteer
  end

  test 'valid factory' do
    assert @volunteer.valid?
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

  test 'external field is default false' do
    assert_equal false, @volunteer.external
  end
end
