require 'test_helper'

class VolunteerStateTest < ActiveSupport::TestCase
  test 'assignment activness makes volunteers state' do
    volunteer = create :volunteer
    refute volunteer.active?
    assignment_one = create :assignment, volunteer: volunteer, period_start: 50.days.ago, period_end: nil
    assert volunteer.active?
    assignment_one.update(period_end: 40.days.ago)
    refute volunteer.active?
    assignment_two = create :assignment, volunteer: volunteer, period_start: 50.days.ago, period_end: nil
    assert volunteer.active?
    assignment_two.update(period_end: Time.zone.today + 100)
    assert volunteer.active?
    assignment_two.update(period_end: 10.days.ago)
    refute volunteer.active?
  end
end
