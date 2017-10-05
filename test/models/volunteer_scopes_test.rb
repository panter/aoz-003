require 'test_helper'

class VolunteerScopesTest < ActiveSupport::TestCase
  def setup
    @today = Time.zone.today
    [:has_assignment, :has_multiple, :has_inactive, :group_offer_member,
     :has_active_and_inactive, :no_assignment].map { |v| make_volunteer v, acceptance: :accepted }
    make_volunteer :active_will_take_more, take_more_assignments: true, acceptance: :accepted
    make_volunteer :inactive_will_take_more, take_more_assignments: true, acceptance: :accepted
    make_volunteer :resigned_inactive, acceptance: :resigned
    make_volunteer :resigned_active, acceptance: :resigned
    group_offer = create :group_offer
    group_offer.volunteers << @group_offer_member
    create_all_assignments
  end

  def create_all_assignments
    [
      [:start_60_days_ago, @has_assignment, @today.days_ago(60), nil],
      [:start_in_one_month, @has_multiple, @today.next_month.end_of_month, nil],
      [:start_7_days_ago, @has_multiple, @today.days_ago(7), nil],
      [:end_15_days_ago, @has_multiple, @today.days_ago(30), @today.days_ago(15)],
      [:end_future, @has_multiple, @today.days_ago(5), @today.next_month.end_of_month],
      [:active_asignment, @has_active_and_inactive, @today - 300, nil],
      [:inactive_asignment, @has_active_and_inactive, @today - 300, @today - 200],
      [:end_30_days_ago, @has_inactive, @today.days_ago(60), @today.days_ago(30)],
      [:active_asignment_for_will, @active_will_take_more, @today - 300, nil],
      [:inactive_asignment_for_will, @inactive_will_take_more, @today - 300, @today - 200],
      [:inactive_asignment_for_resigned, @resigned_inactive, @today - 300, @today - 200],
      [:active_asignment_for_resigned, @resigned_active, @today - 300, nil]
    ].map { |parameters| make_assignment(*parameters) }
  end

  test 'created_between returns only volunteers created within date range' do
    created200 = make_volunteer nil, created_at: @today - 200
    created100 = make_volunteer nil, created_at: @today - 100
    query = Volunteer.created_between(@today - 201, @today - 199)
    refute query.include? created100
    assert query.include? created200
    query = Volunteer.created_between(@today - 201, @today - 99)
    assert query.include? created100
    assert query.include? created200
    query = Volunteer.created_between(@today - 10, @today - 1)
    refute query.include? created100
    refute query.include? created200
  end

  test 'with hours only returns volunteers that have hours' do
    create :hour, hourable: @start_60_days_ago, volunteer: @has_assignment, hours: 4
    query = Volunteer.with_hours
    assert query.include? @has_assignment
    refute query.include? @has_inactive
  end

  test 'has_assignments returns only the ones that have assignments' do
    query = Volunteer.with_assignments.distinct
    assert query.include? @has_assignment
    assert query.include? @has_multiple
    assert query.include? @has_inactive
    refute query.include? @no_assignment
    refute query.include? @group_offer_member
  end

  test 'with_active_assignments returns only volunteers that have active assignments' do
    query = Volunteer.with_active_assignments.distinct
    assert query.include? @has_assignment
    assert query.include? @has_multiple
    assert query.include? @has_active_and_inactive
    refute query.include? @has_inactive
    refute query.include? @no_assignment
    refute query.include? @group_offer_member
  end

  test 'volunteers that have active and inactive assignments are not in only_inactive' do
    query = Volunteer.with_only_inactive_assignments.distinct
    assert query.include? @has_inactive
    refute query.include? @has_active_and_inactive
  end

  test 'with_active_assignments_between returns volunteers with active assignments in date range' do
    query = Volunteer.with_active_assignments_between(@today - 16, @today - 8)
    assert query.include? @has_assignment
    assert query.include? @has_multiple
    refute query.include? @has_inactive
    refute query.include? @no_assignment
    refute query.include? @group_offer_member
  end

  test 'without_assignment returns volunteers with no assignments' do
    query = Volunteer.without_assignment
    refute query.include? @has_assignment
    refute query.include? @has_multiple
    refute query.include? @has_inactive
    assert query.include? @no_assignment
    assert query.include? @group_offer_member
  end

  test 'not_in_any_group_offer returns volunteers not in group offer (as members)' do
    query = Volunteer.not_in_any_group_offer
    assert query.include? @has_assignment
    assert query.include? @has_multiple
    assert query.include? @has_inactive
    assert query.include? @no_assignment
    refute query.include? @group_offer_member
  end

  test 'without_active_assignment.not_in_any_group_offer' do
    query = Volunteer.without_active_assignment.not_in_any_group_offer
    refute query.include? @has_assignment
    assert query.include? @has_multiple
    assert query.include? @has_inactive
    refute query.include? @no_assignment
    refute query.include? @group_offer_member
  end

  test 'will_take_more_assignments selects only active volunteers that take more' do
    query = Volunteer.will_take_more_assignments
    assert query.include? @active_will_take_more
    assert query.include? @inactive_will_take_more
    refute query.include? @has_assignment
  end

  test 'active only returns accepted volunteers that have an active assignment' do
    query = Volunteer.active
    assert query.include? @has_assignment
    assert query.include? @has_multiple
    assert query.include? @has_active_and_inactive
    refute query.include? @has_inactive
    refute query.include? @resigned_inactive
    refute query.include? @resigned_active
  end

  test 'seeking clients shows only volunteers with no active assignments' do
    undecided_no_assignment = make_volunteer nil, acceptance: :undecided
    query = Volunteer.seeking_clients
    refute query.include? @has_active_and_inactive
    assert query.include? @has_inactive
    refute query.include? @resigned_inactive
    refute query.include? @resigned_active
    refute query.include? @has_multiple
    assert query.include? @inactive_will_take_more
    refute query.include? @active_will_take_more
    assert query.include? @no_assignment
    refute query.include? undecided_no_assignment
  end

  test 'seeking_clients_will_take_more only returns accepted volunteers that fullfill all criteria' do
    undecided_no_assignment = make_volunteer nil, acceptance: :undecided
    query = Volunteer.seeking_clients_will_take_more
    refute query.include? @has_active_and_inactive
    assert query.include? @has_inactive
    refute query.include? @resigned_inactive
    refute query.include? @resigned_active
    refute query.include? @has_multiple
    assert query.include? @inactive_will_take_more
    assert query.include? @active_will_take_more
    assert query.include? @no_assignment
    refute query.include? undecided_no_assignment
  end

  def make_volunteer(title, *attributes)
    volunteer = create :volunteer, *attributes
    return volunteer if title.nil?
    instance_variable_set("@#{title}", volunteer)
  end

  def make_assignment(title, volunteer, start_date = nil, end_date = nil)
    assignment = create :assignment, volunteer: volunteer, period_start: start_date,
      period_end: end_date
    return assignment if title.nil?
    instance_variable_set("@#{title}", assignment)
  end
end
