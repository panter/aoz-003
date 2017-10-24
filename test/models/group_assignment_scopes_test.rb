require 'test_helper'

class GroupAssignmentScopesTest < ActiveSupport::TestCase
  test 'start_within' do
    started_before = create_group_assignments 100.days.ago, nil, create(:volunteer)
    started_before_ended_within = create_group_assignments 100.days.ago, 40.days.ago, create(:volunteer)
    started_after = create_group_assignments 10.days.ago, nil, create(:volunteer)
    started_after_ended = create_group_assignments 20.days.ago, 10.days.ago, create(:volunteer)
    started_within_no_end = create_group_assignments 40.days.ago, nil, create(:volunteer)
    started_within_ended_within = create_group_assignments 40.days.ago, 35.days.ago, create(:volunteer)
    started_within_ended_after = create_group_assignments 40.days.ago, 20.days.ago, create(:volunteer)
    query = GroupAssignment.start_within(45.days.ago..30.days.ago)
    assert query.include? started_within_no_end.first
    assert query.include? started_within_ended_within.first
    assert query.include? started_within_ended_after.first
    refute query.include? started_before.first
    refute query.include? started_before_ended_within.first
    refute query.include? started_after.first
    refute query.include? started_after_ended.first
  end

  test 'end_within' do
    started_before = create_group_assignments 100.days.ago, nil, create(:volunteer)
    started_before_ended_within = create_group_assignments 100.days.ago, 40.days.ago, create(:volunteer)
    started_after = create_group_assignments 10.days.ago, nil, create(:volunteer)
    started_after_ended = create_group_assignments 20.days.ago, 10.days.ago, create(:volunteer)
    started_within_no_end = create_group_assignments 40.days.ago, nil, create(:volunteer)
    started_within_ended_within = create_group_assignments 40.days.ago, 35.days.ago, create(:volunteer)
    started_within_ended_after = create_group_assignments 40.days.ago, 20.days.ago, create(:volunteer)
    query = GroupAssignment.end_within(45.days.ago..30.days.ago)
    refute query.include? started_within_no_end.first
    assert query.include? started_within_ended_within.first
    refute query.include? started_within_ended_after.first
    refute query.include? started_before.first
    assert query.include? started_before_ended_within.first
    refute query.include? started_after.first
    refute query.include? started_after_ended.first
  end

  test 'end_after' do
    started_before = create_group_assignments 100.days.ago, nil, create(:volunteer)
    started_before_ended_within = create_group_assignments 100.days.ago, 40.days.ago, create(:volunteer)
    started_after = create_group_assignments 10.days.ago, nil, create(:volunteer)
    started_after_ended = create_group_assignments 20.days.ago, 10.days.ago, create(:volunteer)
    started_within_no_end = create_group_assignments 40.days.ago, nil, create(:volunteer)
    started_within_ended_within = create_group_assignments 40.days.ago, 35.days.ago, create(:volunteer)
    started_within_ended_after = create_group_assignments 40.days.ago, 20.days.ago, create(:volunteer)
    query = GroupAssignment.end_after(30.days.ago)
    refute query.include? started_within_no_end.first
    refute query.include? started_within_ended_within.first
    assert query.include? started_within_ended_after.first
    refute query.include? started_before.first
    refute query.include? started_before_ended_within.first
    refute query.include? started_after.first
    assert query.include? started_after_ended.first
  end

  test 'end_before' do
    started_before = create_group_assignments 100.days.ago, nil, create(:volunteer)
    started_before_ended_within = create_group_assignments 100.days.ago, 40.days.ago, create(:volunteer)
    started_after = create_group_assignments 10.days.ago, nil, create(:volunteer)
    started_after_ended = create_group_assignments 20.days.ago, 10.days.ago, create(:volunteer)
    started_within_no_end = create_group_assignments 40.days.ago, nil, create(:volunteer)
    started_within_ended_within = create_group_assignments 40.days.ago, 35.days.ago, create(:volunteer)
    started_within_ended_after = create_group_assignments 40.days.ago, 20.days.ago, create(:volunteer)
    query = GroupAssignment.end_before(30.days.ago)
    refute query.include? started_within_no_end.first
    assert query.include? started_within_ended_within.first
    refute query.include? started_within_ended_after.first
    refute query.include? started_before.first
    assert query.include? started_before_ended_within.first
    refute query.include? started_after.first
    refute query.include? started_after_ended.first
  end

  test 'start_before' do
    started_before = create_group_assignments 100.days.ago, nil, create(:volunteer)
    started_before_ended_within = create_group_assignments 100.days.ago, 40.days.ago, create(:volunteer)
    started_after = create_group_assignments 10.days.ago, nil, create(:volunteer)
    started_after_ended = create_group_assignments 20.days.ago, 10.days.ago, create(:volunteer)
    started_within_no_end = create_group_assignments 40.days.ago, nil, create(:volunteer)
    started_within_ended_within = create_group_assignments 40.days.ago, 35.days.ago, create(:volunteer)
    started_within_ended_after = create_group_assignments 40.days.ago, 20.days.ago, create(:volunteer)
    query = GroupAssignment.start_before(45.days.ago)
    refute query.include? started_within_no_end.first
    refute query.include? started_within_ended_within.first
    refute query.include? started_within_ended_after.first
    assert query.include? started_before.first
    assert query.include? started_before_ended_within.first
    refute query.include? started_after.first
    refute query.include? started_after_ended.first
  end

  test 'not_end_before' do
    started_before = create_group_assignments 100.days.ago, nil, create(:volunteer)
    started_before_ended_within = create_group_assignments 100.days.ago, 40.days.ago, create(:volunteer)
    started_after = create_group_assignments 10.days.ago, nil, create(:volunteer)
    started_after_ended = create_group_assignments 20.days.ago, 10.days.ago, create(:volunteer)
    started_within_no_end = create_group_assignments 40.days.ago, nil, create(:volunteer)
    started_within_ended_within = create_group_assignments 40.days.ago, 35.days.ago, create(:volunteer)
    started_within_ended_after = create_group_assignments 40.days.ago, 20.days.ago, create(:volunteer)
    query = GroupAssignment.not_end_before(30.days.ago)
    refute query.include? started_within_no_end.first
    refute query.include? started_within_ended_within.first
    assert query.include? started_within_ended_after.first
    refute query.include? started_before.first
    refute query.include? started_before_ended_within.first
    refute query.include? started_after.first
    assert query.include? started_after_ended.first
  end

  test 'active_between' do
    started_before = create_group_assignments 100.days.ago, nil, create(:volunteer)
    started_before_ended_within = create_group_assignments 100.days.ago, 40.days.ago, create(:volunteer)
    started_before_ended_before = create_group_assignments 100.days.ago, 50.days.ago, create(:volunteer)
    started_after = create_group_assignments 10.days.ago, nil, create(:volunteer)
    started_after_ended = create_group_assignments 20.days.ago, 10.days.ago, create(:volunteer)
    started_within_no_end = create_group_assignments 40.days.ago, nil, create(:volunteer)
    started_within_ended_within = create_group_assignments 40.days.ago, 35.days.ago, create(:volunteer)
    started_within_ended_after = create_group_assignments 40.days.ago, 20.days.ago, create(:volunteer)
    query = GroupAssignment.active_between(45.days.ago, 30.days.ago)
    assert query.include? started_within_no_end.first
    assert query.include? started_within_ended_within.first
    assert query.include? started_within_ended_after.first
    assert query.include? started_before.first
    assert query.include? started_before_ended_within.first
    refute query.include? started_after.first
    refute query.include? started_after_ended.first
    refute query.include? started_before_ended_before
  end

  def create_group_assignments(start_date = nil, end_date = nil, *volunteers)
    group_offer = create :group_offer, necessary_volunteers: volunteers.size, volunteers: volunteers
    volunteers.map do |volunteer|
      GroupAssignment.create(volunteer: volunteer, group_offer: group_offer, period_start: start_date,
        period_end: end_date)
    end
  end
end
