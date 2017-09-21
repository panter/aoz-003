require 'test_helper'

class VolunteerScopesTest < ActiveSupport::TestCase
  def setup
    @today = Time.zone.now.to_date
    @with_assignment = create :volunteer
    @with_multiple_assignments = create :volunteer
    @with_inactive_assignment = create :volunteer
    @with_active_and_inactive_assignment = create :volunteer
    @no_assignment = create :volunteer
    assignments_make_parameters.map { |parameters| make_assignment(*parameters) }
  end

  def assignments_make_parameters
    [
      ['start_60_days_ago', @with_assignment, @now.days_ago(60), nil],
      ['start_in_one_month', @with_multiple_assignments, @now.next_month.end_of_month, nil],
      ['start_7_days_ago', @with_multiple_assignments, @now.days_ago(7), nil],
      ['end_15_days_ago', @with_multiple_assignments, @now.days_ago(30), @now.days_ago(15)],
      ['end_future', @with_multiple_assignments, @now.days_ago(5), @now.next_month.end_of_month],
      ['active_asignment', @with_active_and_inactive_assignment, @today - 300, nil],
      ['inactive_asignment', @with_active_and_inactive_assignment, @today - 300, @today - 200],
      ['end_30_days_ago', @with_inactive_assignment, @now.days_ago(60), @now.days_ago(30)]
    ].map { |parameters| make_assignment(*parameters) }
    @group_offer_member = create :volunteer
    @group_offer_responsible = create :volunteer
    group_offer = create :group_offer, responsible: @group_offer_responsible
    group_offer.volunteers << @group_offer_member
  end

  test 'with_assignments returns only the ones that have assignments' do
    query = Volunteer.with_assignments.distinct
    assert query.include? @with_assignment
    assert query.include? @with_multiple_assignments
    assert query.include? @with_inactive_assignment
    refute query.include? @no_assignment
    refute query.include? @group_offer_member
    refute query.include? @group_offer_responsible
  end

  test 'with_active_assignments returns only volunteers that have active assignments' do
    query = Volunteer.with_active_assignments.distinct
    assert query.include? @with_assignment
    assert query.include? @with_multiple_assignments
    assert query.include? @with_active_and_inactive_assignment
    refute query.include? @with_inactive_assignment
    refute query.include? @no_assignment
    refute query.include? @group_offer_member
    refute query.include? @group_offer_responsible
  end

  test 'with_inactive_assignments' do
    query = Volunteer.with_inactive_assignments.distinct
    assert query.include? @with_inactive_assignment
    refute query.include? @with_active_and_inactive_assignment
  end

  test 'with_active_assignments_between returns volunteers with active assignments in date range' do
    query = Volunteer.with_active_assignments_between(@today - 16, @today - 8)
    assert query.include? @with_assignment
    assert query.include? @with_multiple_assignments
    refute query.include? @with_inactive_assignment
    refute query.include? @no_assignment
    refute query.include? @group_offer_member
    refute query.include? @group_offer_responsible
  end

  test 'without_assignment returns volunteers with no assignments' do
    query = Volunteer.without_assignment
    refute query.include? @with_assignment
    refute query.include? @with_multiple_assignments
    refute query.include? @with_inactive_assignment
    assert query.include? @no_assignment
    assert query.include? @group_offer_member
    assert query.include? @group_offer_responsible
    assert_equal 3, query.count
  end

  test 'not_in_any_group_offer returns volunteers not in group offer (as members)' do
    query = Volunteer.not_in_any_group_offer
    assert query.include? @with_assignment
    assert query.include? @with_multiple_assignments
    assert query.include? @with_inactive_assignment
    assert query.include? @no_assignment
    refute query.include? @group_offer_member
    assert query.include? @group_offer_responsible
    assert_equal 5, query.count
  end

  test 'not_responsible returns volunteers not responsible for group offer' do
    query = Volunteer.not_responsible
    assert query.include? @with_assignment
    assert query.include? @with_multiple_assignments
    assert query.include? @with_inactive_assignment
    assert query.include? @no_assignment
    assert query.include? @group_offer_member
    refute query.include? @group_offer_responsible
    assert_equal 5, query.count
  end

  test 'without_active_assignment.not_responsible.not_in_any_group_offer' do
    query = Volunteer.without_active_assignment.not_responsible.not_in_any_group_offer
    refute query.include? @with_assignment
    assert query.include? @with_multiple_assignments
    assert query.include? @with_inactive_assignment
    refute query.include? @no_assignment
    refute query.include? @group_offer_member
    refute query.include? @group_offer_responsible
    assert_equal 2, query.count
  end

  def make_assignment(title, volunteer, start_date = nil, end_date = nil)
    assignment = create :assignment, volunteer: volunteer, period_start: start_date,
      period_end: end_date
    instance_variable_set("@#{title}", assignment)
  end
end
