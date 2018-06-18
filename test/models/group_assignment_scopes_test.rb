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
    query = GroupAssignment.start_within(45.days.ago, 30.days.ago)
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
    query = GroupAssignment.end_within(45.days.ago, 30.days.ago)
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

  test 'termination_submitted_scope_test' do
    superadmin = create :user
    started_no_end = create_group_assignments 100.days.ago, nil
    started_with_end = create_group_assignments 100.days.ago, 2.days.ago
    started_with_end.update(period_end_set_by: superadmin)
    submitted = create_group_assignments 100.days.ago, 2.days.ago
    submitted.update(period_end_set_by: superadmin, termination_submitted_at: 2.days.ago,
      termination_submitted_by: superadmin)
    verified = create_group_assignments 100.days.ago, 2.days.ago
    verified.update(period_end_set_by: superadmin, termination_submitted_at: 2.days.ago,
      termination_submitted_by: superadmin, termination_verified_at: 2.days.ago,
      termination_verified_by: superadmin)
    query = GroupAssignment.termination_submitted
    refute query.include? started_no_end
    refute query.include? started_with_end
    assert query.include? submitted
    assert query.include? verified
  end

  test 'termination_not_submitted scope test' do
    superadmin = create :user
    started_no_end = create_group_assignments 100.days.ago, nil
    started_with_end = create_group_assignments 100.days.ago, 2.days.ago
    started_with_end.update(period_end_set_by: superadmin)
    submitted = create_group_assignments 100.days.ago, 2.days.ago
    submitted.update(period_end_set_by: superadmin, termination_submitted_at: 2.days.ago,
      termination_submitted_by: superadmin)
    verified = create_group_assignments 100.days.ago, 2.days.ago
    verified.update(period_end_set_by: superadmin, termination_submitted_at: 2.days.ago,
      termination_submitted_by: superadmin, termination_verified_at: 2.days.ago,
      termination_verified_by: superadmin)
    query = GroupAssignment.termination_not_submitted
    assert query.include? started_no_end
    assert query.include? started_with_end
    refute query.include? submitted
    refute query.include? verified
  end

  test 'unterminated scope test' do
    superadmin = create :user
    started_no_end = create_group_assignments 100.days.ago, nil
    started_with_end = create_group_assignments 100.days.ago, 2.days.ago
    started_with_end.update(period_end_set_by: superadmin)
    submitted = create_group_assignments 100.days.ago, 2.days.ago
    submitted.update(period_end_set_by: superadmin, termination_submitted_at: 2.days.ago,
      termination_submitted_by: superadmin)
    verified = create_group_assignments 100.days.ago, 2.days.ago
    verified.update(period_end_set_by: superadmin, termination_submitted_at: 2.days.ago,
      termination_submitted_by: superadmin, termination_verified_at: 2.days.ago,
      termination_verified_by: superadmin)
    query = GroupAssignment.unterminated
    assert query.include? started_no_end
    assert query.include? started_with_end
    assert query.include? submitted
    refute query.include? verified
    query_deleted = GroupAssignment.with_deleted.unterminated
    assert query_deleted.include? started_no_end
    assert query_deleted.include? started_with_end
    assert query_deleted.include? submitted
    refute query_deleted.include? verified
  end

  test 'terminated scope test' do
    superadmin = create :user
    started_no_end = create_group_assignments 100.days.ago, nil
    started_with_end = create_group_assignments 100.days.ago, 2.days.ago
    started_with_end.update(period_end_set_by: superadmin)
    submitted = create_group_assignments 100.days.ago, 2.days.ago
    submitted.update(period_end_set_by: superadmin, termination_submitted_at: 2.days.ago,
      termination_submitted_by: superadmin)
    verified = create_group_assignments 100.days.ago, 2.days.ago
    verified.update(period_end_set_by: superadmin, termination_submitted_at: 2.days.ago,
      termination_submitted_by: superadmin, termination_verified_at: 2.days.ago,
      termination_verified_by: superadmin)
    query = GroupAssignment.terminated
    refute query.include? started_no_end
    refute query.include? started_with_end
    refute query.include? submitted
    assert query.include? verified
    query_deleted = GroupAssignment.with_deleted.terminated
    refute query_deleted.include? started_no_end
    refute query_deleted.include? started_with_end
    refute query_deleted.include? submitted
    assert query_deleted.include? verified
  end

  test 'with_actively_registered_volunteer returns group_assignments of volunteers with_actively_registered_user' do
    volunteer1 = create :volunteer, :external
    volunteer2 = create :volunteer, :external
    volunteer3 = create :volunteer_with_user
    volunteer4 = create :volunteer_with_user
    group_assignment1 = create :group_assignment, volunteer: volunteer1
    group_assignment2 = create :group_assignment, volunteer: volunteer2
    group_assignment3 = create :group_assignment, volunteer: volunteer3
    group_assignment4 = create :group_assignment, volunteer: volunteer4

    # faking user sign in by setting last_sign_in_at an arbitrary date
    [volunteer3, volunteer4].each { |v| v.user.update(last_sign_in_at: Time.now) }

    group_assignments = GroupAssignment.with_actively_registered_volunteer

    assert_not_includes group_assignments, group_assignment1
    assert_not_includes group_assignments, group_assignment2
    assert_includes group_assignments, group_assignment3
    assert_includes group_assignments, group_assignment4
  end

  def create_group_assignments(start_date = nil, end_date = nil)
    volunteer = create :volunteer
    volunteer.contact.update(first_name: FFaker::Name.unique.first_name)
    group_offer = create :group_offer, necessary_volunteers: 1
    GroupAssignment.create!(volunteer: volunteer, group_offer: group_offer,
      period_start: start_date, period_end: end_date)
  end
end
