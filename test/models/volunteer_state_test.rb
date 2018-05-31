require 'test_helper'

class VolunteerStateTest < ActiveSupport::TestCase
  test 'volunteer_inactive_is_not_active' do
    volunteer = create :volunteer
    assert_not volunteer.active
  end

  test 'volunteer_with_inactive_assignment_isnt_active' do
    volunteer = create :volunteer
    assignment = create :assignment_blank_period, volunteer: volunteer
    assert assignment.inactive?
    assert_not volunteer.active
    assignment.update(period_start: 10.days.ago)
    assert assignment.active?
    assert volunteer.active
    assignment.update(period_end: 5.days.ago)
    assert assignment.inactive?
    assert_not volunteer.active
  end

  test 'volunteer_with_inactive_assignments_and_one_active_has_correct_state' do
    volunteer = create :volunteer
    assignment_one = create :assignment_blank_period, volunteer: volunteer
    create :assignment_blank_period, volunteer: volunteer
    assignment_three = create :assignment_blank_period, volunteer: volunteer
    Assignment.all.map { |assignment| assert assignment.inactive? }
    assert_not volunteer.active
    assignment_three.update(period_start: 10.days.ago)
    assert assignment_three.active?
    assert volunteer.active
    assignment_three.update(period_end: 5.days.ago)
    assert assignment_three.inactive?
    assert_not volunteer.active
    assignment_one.update(period_start: 10.days.ago)
    assert volunteer.active
    assignment_one.update(period_start: Time.zone.today + 10)
    assert_not volunteer.active
  end

  test 'volunteer_with_inactive_group_assignment_isnt_active' do
    volunteer = create :volunteer
    group_offer = create :group_offer
    group_assignment = GroupAssignment.create(volunteer: volunteer, group_offer: group_offer)
    assert group_assignment.inactive?
    assert_not volunteer.active
    group_assignment.update(period_start: 10.days.ago)
    assert group_assignment.active?
    assert volunteer.active
    group_assignment.update(period_end: 5.days.ago)
    assert group_assignment.inactive?
    assert_not volunteer.active
  end

  test 'volunteer_with_inactive_group_assignments_and_one_active_is_active' do
    volunteer = create :volunteer
    group_assignment_one = GroupAssignment.create(volunteer: volunteer, group_offer: create(:group_offer))
    group_assignment_two = GroupAssignment.create(volunteer: volunteer, group_offer: create(:group_offer))
    GroupAssignment.create(volunteer: volunteer, group_offer: create(:group_offer))
    GroupAssignment.all.map { |group_assignment| assert group_assignment.inactive? }
    assert_not volunteer.active
    group_assignment_one.update(period_start: 10.days.ago)
    assert group_assignment_one.active?
    assert volunteer.active
    group_assignment_one.update(period_end: 5.days.ago)
    assert group_assignment_one.inactive?
    assert_not volunteer.active
    group_assignment_two.update(period_start: 10.days.ago)
    assert group_assignment_two.active?
    assert volunteer.active
    group_assignment_two.update(period_end: 5.days.ago)
    assert group_assignment_two.inactive?
    assert_not volunteer.active
  end

  test 'volunteer_with_inactive_mixed_assignments_and_one_active_is_active' do
    volunteer = create :volunteer
    group_assignment = GroupAssignment.create(volunteer: volunteer, group_offer: create(:group_offer))
    GroupAssignment.create(volunteer: volunteer, group_offer: create(:group_offer))
    GroupAssignment.create(volunteer: volunteer, group_offer: create(:group_offer))
    GroupAssignment.all.map { |g_assignment| assert g_assignment.inactive? }
    assignment = create :assignment_blank_period, volunteer: volunteer
    create :assignment_blank_period, volunteer: volunteer
    create :assignment_blank_period, volunteer: volunteer
    Assignment.all.map { |tandem| assert tandem.inactive? }
    assert_not volunteer.active
    group_assignment.update(period_start: 10.days.ago)
    assert group_assignment.active?
    assert volunteer.active
    group_assignment.update(period_end: 5.days.ago)
    assert group_assignment.inactive?
    assert_not volunteer.active
    assignment.update(period_start: 10.days.ago)
    assert assignment.active?
    assert volunteer.active
    assignment.update(period_end: 5.days.ago)
    assert assignment.inactive?
    assert_not volunteer.active
  end

  test 'volunteer_assignment_will_end_activeness_ends_after_period_end_reached' do
    volunteer = create :volunteer
    create :assignment, volunteer: volunteer, period_start: 10.days.ago,
      period_end: Time.zone.today + 20
    Assignment.all.map { |tandem| assert tandem.active? }
    assert volunteer.active?
    assert volunteer.active # active field is true
    assert Volunteer.active.include? volunteer
    travel_to Time.zone.today + 30
    Assignment.all.map { |tandem| assert tandem.inactive? }
    assert_not volunteer.active?
    assert volunteer.active # still expect true, because no update triggered
    assert_not Volunteer.active.include? volunteer
  end

  test 'volunteer_assignment_will_end_and_will_not_end_stays_active' do
    volunteer = create :volunteer
    assignment_ends = create :assignment, volunteer: volunteer, period_start: 10.days.ago,
      period_end: Time.zone.today + 20
    assignment_doesnt_end = create :assignment, volunteer: volunteer, period_start: 10.days.ago,
      period_end: nil
    Assignment.all.map { |tandem| assert tandem.active? }
    assert Volunteer.active.include? volunteer
    travel_to Time.zone.today + 30
    assert assignment_ends.inactive?
    assert volunteer.active?
    assert volunteer.active
    assert Volunteer.active.include? volunteer
    assignment_doesnt_end.update(period_end: assignment_ends.period_end)
    assert assignment_doesnt_end.inactive?
    assert_not volunteer.active?
    assert_not volunteer.active # update on assignment triggered update, so false expected
    assert_not Volunteer.active.include? volunteer
  end

  test 'mixed_assignment_group_assignment_might_end_ends_correctly' do
    volunteer = create :volunteer
    assignment = create :assignment, volunteer: volunteer, period_start: 10.days.ago,
      period_end: Time.zone.today + 20
    group_assignment = GroupAssignment.create(volunteer: volunteer,
      group_offer: create(:group_offer), period_start: 10.days.ago, period_end: nil)
    Assignment.all.map { |tandem| assert tandem.active? }
    GroupOffer.all.map { |g_assignment| assert g_assignment.active? }
    assert Volunteer.active.include? volunteer
    travel_to Time.zone.today + 30
    assert assignment.inactive?
    assert volunteer.active?
    assert volunteer.active
    assert Volunteer.active.include? volunteer
    group_assignment.update(period_end: assignment.period_end)
    assert_not volunteer.active?
    assert_not volunteer.active # update on group assignment triggered update, so false
    assert_not Volunteer.active.include? volunteer
  end

  test 'state_active_method_for_single_volunteer_instance' do
    volunteer = create :volunteer_with_user, acceptance: :undecided
    assert_not volunteer.accepted?
    assert_not volunteer.active?
    volunteer.update(acceptance: 'accepted')
    assert volunteer.accepted?
    assert_not volunteer.active?
    assignment = create :assignment, volunteer: volunteer, period_start: nil, period_end: nil
    assert_not volunteer.active?
    assignment.update(period_start: 10.days.ago)
    assert volunteer.active?
    assignment.update(period_end: 5.days.ago)
    assert_not volunteer.active?
    group_offer = create :group_offer
    group_assignment = GroupAssignment.create(volunteer: volunteer, group_offer: group_offer)
    assert_not volunteer.active?
    group_assignment.update(period_start: 10.days.ago)
    assert volunteer.active?
    group_assignment.update(period_end: Time.zone.today + 10)
    assert volunteer.active?
    travel_to Time.zone.today + 15
    assert_not volunteer.active?
  end

  test 'state_inactive_method_for_single_volunteer_instance' do
    volunteer = create :volunteer_with_user, acceptance: :undecided
    assert_not volunteer.accepted?
    assert_not volunteer.inactive?
    volunteer.update(acceptance: 'accepted')
    assert volunteer.accepted?
    assert volunteer.inactive?
    assignment = create :assignment, volunteer: volunteer, period_start: nil, period_end: nil
    assert volunteer.inactive?
    assignment.update(period_start: 10.days.ago)
    assert_not volunteer.inactive?
    assignment.update(period_end: 5.days.ago)
    assert volunteer.inactive?
    group_offer = create :group_offer
    group_assignment = GroupAssignment.create(volunteer: volunteer, group_offer: group_offer)
    assert volunteer.inactive?
    group_assignment.update(period_start: 10.days.ago)
    assert_not volunteer.inactive?
    group_assignment.update(period_end: Time.zone.today + 10)
    assert_not volunteer.inactive?
    travel_to Time.zone.today + 15
    assert volunteer.inactive?
  end
end
