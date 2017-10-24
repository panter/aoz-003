require 'test_helper'

class VolunteerStateTest < ActiveSupport::TestCase
  test 'active? method' do
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
    group_assignment_one = GroupAssignment.create(volunteer: volunteer, period_start: 20.days.ago,
      period_end: nil, group_offer: create(:group_offer))
    assert volunteer.active?
    group_assignment_one.update(period_end: 10.days.ago)
    refute volunteer.active?
    group_assignment_two = GroupAssignment.create(volunteer: volunteer, period_start: 20.days.ago,
      period_end: Time.zone.today + 100, group_offer: create(:group_offer))
    assert volunteer.active?
    group_assignment_two.update(period_end: 10.days.ago)
    refute volunteer.active?
  end

  test 'inactive? method' do
    volunteer = create :volunteer
    assert volunteer.inactive?
    assignment_one = create :assignment, volunteer: volunteer, period_start: 50.days.ago, period_end: nil
    refute volunteer.inactive?
    assignment_one.update(period_end: 40.days.ago)
    assert volunteer.inactive?
    assignment_two = create :assignment, volunteer: volunteer, period_start: 50.days.ago, period_end: nil
    refute volunteer.inactive?
    assignment_two.update(period_end: Time.zone.today + 100)
    refute volunteer.inactive?
    assignment_two.update(period_end: 10.days.ago)
    assert volunteer.inactive?
    group_assignment_one = GroupAssignment.create(volunteer: volunteer, period_start: 20.days.ago,
      period_end: nil, group_offer: create(:group_offer))
    refute volunteer.inactive?
    group_assignment_one.update(period_end: 10.days.ago)
    assert volunteer.inactive?
    group_assignment_two = GroupAssignment.create(volunteer: volunteer, period_start: 20.days.ago,
      period_end: Time.zone.today + 100, group_offer: create(:group_offer))
    refute volunteer.inactive?
    group_assignment_two.update(period_end: 10.days.ago)
    assert volunteer.inactive?
  end

  test 'state method' do
    volunteer = create :volunteer, acceptance: 0
    assert_equal 'undecided', volunteer.state
    volunteer.accepted!
    assert_equal :inactive, volunteer.state
    assignment_one = create :assignment, volunteer: volunteer, period_start: 50.days.ago, period_end: nil
    assert_equal :active, volunteer.state
    assignment_one.update(period_end: 40.days.ago)
    assert_equal :inactive, volunteer.state
    assignment_two = create :assignment, volunteer: volunteer, period_start: 50.days.ago, period_end: nil
    assert_equal :active, volunteer.state
    assignment_two.update(period_end: Time.zone.today + 100)
    assert_equal :active, volunteer.state
    assignment_two.update(period_end: 10.days.ago)
    assert_equal :inactive, volunteer.state
    group_assignment_one = GroupAssignment.create(volunteer: volunteer, period_start: 20.days.ago,
      period_end: nil, group_offer: create(:group_offer))
    assert_equal :active, volunteer.state
    group_assignment_one.update(period_end: 10.days.ago)
    assert_equal :inactive, volunteer.state
    group_assignment_two = GroupAssignment.create(volunteer: volunteer, period_start: 20.days.ago,
      period_end: Time.zone.today + 100, group_offer: create(:group_offer))
    assert_equal :active, volunteer.state
    group_assignment_two.update(period_end: 10.days.ago)
    assert_equal :inactive, volunteer.state
  end
end
