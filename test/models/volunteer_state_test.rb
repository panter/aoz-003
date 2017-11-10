require 'test_helper'

class VolunteerStateTest < ActiveSupport::TestCase
  def create_basic_accepted_volunteer
    volunteer_user = create :user_volunteer, volunteer: create(:volunteer)
    volunteer_user.volunteer
  end


  test 'volunteer_inactive_is_not_active' do
    volunteer = create_basic_accepted_volunteer
    assert_not volunteer.active
  end

  test 'volunteer_with_inactive_assignment_isnt_active' do
    volunteer = create_basic_accepted_volunteer
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
    volunteer = create_basic_accepted_volunteer
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
    volunteer = create_basic_accepted_volunteer
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
    volunteer = create_basic_accepted_volunteer
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
    volunteer = create_basic_accepted_volunteer
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
end
