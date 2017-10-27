require 'test_helper'

class GroupAssignmentScopesTest < ActiveSupport::TestCase
  test 'start_within' do
    started_before = create_group_assignments 100.days.ago, nil
    started_before_ended_within = create_group_assignments 100.days.ago, 40.days.ago
    started_after = create_group_assignments 10.days.ago, nil
    started_after_ended = create_group_assignments 20.days.ago, 10.days.ago
    started_within_no_end = create_group_assignments 40.days.ago, nil
    started_within_ended_within = create_group_assignments 40.days.ago, 35.days.ago
    started_within_ended_after = create_group_assignments 40.days.ago, 20.days.ago
    query = GroupAssignment.start_within(45.days.ago..30.days.ago)
    assert query.include? started_within_no_end
    assert query.include? started_within_ended_within
    assert query.include? started_within_ended_after
    refute query.include? started_before
    refute query.include? started_before_ended_within
    refute query.include? started_after
    refute query.include? started_after_ended
  end

  test 'end_within' do
    started_before = create_group_assignments 100.days.ago, nil
    started_before_ended_within = create_group_assignments 100.days.ago, 40.days.ago
    started_after = create_group_assignments 10.days.ago, nil
    started_after_ended = create_group_assignments 20.days.ago, 10.days.ago
    started_within_no_end = create_group_assignments 40.days.ago, nil
    started_within_ended_within = create_group_assignments 40.days.ago, 35.days.ago
    started_within_ended_after = create_group_assignments 40.days.ago, 20.days.ago
    query = GroupAssignment.end_within(45.days.ago..30.days.ago)
    refute query.include? started_within_no_end
    assert query.include? started_within_ended_within
    refute query.include? started_within_ended_after
    refute query.include? started_before
    assert query.include? started_before_ended_within
    refute query.include? started_after
    refute query.include? started_after_ended
  end

  test 'end_after' do
    started_before = create_group_assignments 100.days.ago, nil
    started_before_ended_within = create_group_assignments 100.days.ago, 40.days.ago
    started_after = create_group_assignments 10.days.ago, nil
    started_after_ended = create_group_assignments 20.days.ago, 10.days.ago
    started_within_no_end = create_group_assignments 40.days.ago, nil
    started_within_ended_within = create_group_assignments 40.days.ago, 35.days.ago
    started_within_ended_after = create_group_assignments 40.days.ago, 20.days.ago
    query = GroupAssignment.end_after(30.days.ago)
    refute query.include? started_within_no_end
    refute query.include? started_within_ended_within
    assert query.include? started_within_ended_after
    refute query.include? started_before
    refute query.include? started_before_ended_within
    refute query.include? started_after
    assert query.include? started_after_ended
  end

  test 'end_before' do
    started_before = create_group_assignments 100.days.ago, nil
    started_before_ended_within = create_group_assignments 100.days.ago, 40.days.ago
    started_after = create_group_assignments 10.days.ago, nil
    started_after_ended = create_group_assignments 20.days.ago, 10.days.ago
    started_within_no_end = create_group_assignments 40.days.ago, nil
    started_within_ended_within = create_group_assignments 40.days.ago, 35.days.ago
    started_within_ended_after = create_group_assignments 40.days.ago, 20.days.ago
    query = GroupAssignment.end_before(30.days.ago)
    refute query.include? started_within_no_end
    assert query.include? started_within_ended_within
    refute query.include? started_within_ended_after
    refute query.include? started_before
    assert query.include? started_before_ended_within
    refute query.include? started_after
    refute query.include? started_after_ended
  end

  test 'start_before' do
    started_before = create_group_assignments 100.days.ago, nil
    started_before_ended_within = create_group_assignments 100.days.ago, 40.days.ago
    started_after = create_group_assignments 10.days.ago, nil
    started_after_ended = create_group_assignments 20.days.ago, 10.days.ago
    started_within_no_end = create_group_assignments 40.days.ago, nil
    started_within_ended_within = create_group_assignments 40.days.ago, 35.days.ago
    started_within_ended_after = create_group_assignments 40.days.ago, 20.days.ago
    query = GroupAssignment.start_before(45.days.ago)
    refute query.include? started_within_no_end
    refute query.include? started_within_ended_within
    refute query.include? started_within_ended_after
    assert query.include? started_before
    assert query.include? started_before_ended_within
    refute query.include? started_after
    refute query.include? started_after_ended
  end

  test 'active_between' do
    started_before = create_group_assignments 100.days.ago, nil
    started_before_ended_within = create_group_assignments 100.days.ago, 40.days.ago
    started_before_ended_before = create_group_assignments 100.days.ago, 50.days.ago
    started_after = create_group_assignments 10.days.ago, nil
    started_after_ended = create_group_assignments 20.days.ago, 10.days.ago
    started_within_no_end = create_group_assignments 40.days.ago, nil
    started_within_ended_within = create_group_assignments 40.days.ago, 35.days.ago
    started_within_ended_after = create_group_assignments 40.days.ago, 20.days.ago
    query = GroupAssignment.active_between(45.days.ago, 30.days.ago)
    assert query.include? started_within_no_end
    assert query.include? started_within_ended_within
    assert query.include? started_within_ended_after
    assert query.include? started_before
    assert query.include? started_before_ended_within
    refute query.include? started_after
    refute query.include? started_after_ended
    refute query.include? started_before_ended_before
  end

  def create_group_assignments(start_date = nil, end_date = nil)
    volunteer = create :volunteer
    volunteer.contact.update(first_name: Faker::Name.first_name)
    group_offer = create :group_offer, necessary_volunteers: 1
    GroupAssignment.create!(volunteer: volunteer, group_offer: group_offer,
      period_start: start_date, period_end: end_date)
  end
end
