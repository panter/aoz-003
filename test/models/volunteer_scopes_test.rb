require 'test_helper'
require 'utility/group_offer_and_assignment'

class VolunteerScopesTest < ActiveSupport::TestCase
  include GroupOfferAndAssignment

  def setup
    @today = Time.zone.today
    [:has_assignment, :has_multiple, :has_inactive, :group_offer_member,
     :has_active_and_inactive, :no_assignment].map { |v| make_volunteer v, acceptance: :accepted }
    make_volunteer(:active_will_take_more, take_more_assignments: true, acceptance: :accepted)
    make_volunteer(:inactive_will_take_more, take_more_assignments: true, acceptance: :accepted)
    make_volunteer(:resigned_inactive, acceptance: :resigned)
    make_volunteer(:resigned_active, acceptance: :resigned)
    group_offer = create :group_offer
    group_offer.volunteers << @group_offer_member
    create_all_assignments
  end

  def create_all_assignments
    [
      { title: :start_60_days_ago, volunteer: @has_assignment,
        start_date: @today.days_ago(60) },
      { title: :start_in_one_month, volunteer: @has_multiple,
        start_date: @today.next_month.end_of_month },
      { title: :start_7_days_ago, volunteer: @has_multiple, start_date: @today.days_ago(7) },
      { title: :end_15_days_ago, volunteer: @has_multiple,
        start_date: @today.days_ago(30), end_date: @today.days_ago(15) },
      { title: :end_future, volunteer: @has_multiple, start_date: @today.days_ago(5),
        end_date: @today.next_month.end_of_month },
      { title: :active_asignment, volunteer: @has_active_and_inactive, start_date: @today - 300 },
      { title: :inactive_asignment, volunteer: @has_active_and_inactive, start_date: @today - 300,
        end_date: @today - 200 },
      { title: :end_30_days_ago, volunteer: @has_inactive, start_date: @today.days_ago(60),
        end_date: @today.days_ago(30) },
      { title: :active_asignment_for_will, volunteer: @active_will_take_more,
        start_date: @today - 300 },
      { title: :inactive_asignment_for_will, volunteer: @inactive_will_take_more,
        start_date: @today - 300, end_date: @today - 200 },
      { title: :inactive_asignment_for_resigned, volunteer: @resigned_inactive,
        start_date: @today - 300, end_date: @today - 200 },
      { title: :active_asignment_for_resigned, volunteer: @resigned_active,
        start_date: @today - 300 }
    ].each { |params| make_assignment(params) }
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

  test 'created_before' do
    created_before = create :volunteer
    created_before.update(created_at: 100.days.ago)
    created_after = create :volunteer
    created_after.update(created_at: 10.days.ago)
    query = Volunteer.created_before(50.days.ago)
    assert query.include? created_before
    refute query.include? created_after
  end

  test 'created_after' do
    Volunteer.with_deleted.map(&:really_destroy!)
    created_before = create :volunteer
    created_before.update(created_at: 100.days.ago)
    created_after = create :volunteer
    created_after.update(created_at: 10.days.ago)
    query = Volunteer.created_after(50.days.ago)
    refute query.include? created_before
    assert query.include? created_after
  end

  test 'with_group_assignments' do
    Volunteer.with_deleted.map(&:really_destroy!)
    volunteer_with_ga = create :volunteer
    create_group_assignments(create(:group_offer), 100.days.ago, nil, volunteer_with_ga)
    volunteer_without_ga = create :volunteer
    query = Volunteer.with_group_assignments
    assert query.include? volunteer_with_ga
    refute query.include? volunteer_without_ga
  end

  test 'without_group_assignments' do
    Volunteer.with_deleted.map(&:really_destroy!)
    volunteer_with_ga = create :volunteer
    create_group_assignments(create(:group_offer), 100.days.ago, nil, volunteer_with_ga)
    volunteer_without_ga = create :volunteer
    query = Volunteer.without_group_assignments
    refute query.include? volunteer_with_ga
    assert query.include? volunteer_without_ga
  end

  test 'with_active_group_assignments_between' do
    Volunteer.with_deleted.map(&:really_destroy!)
    started_before_end_after = create :volunteer
    create_group_assignments(create(:group_offer), 100.days.ago, 10.days.ago, started_before_end_after)
    started_before_no_end = create :volunteer
    create_group_assignments(create(:group_offer), 100.days.ago, nil, started_before_no_end)
    started_within_end_after = create :volunteer
    create_group_assignments(create(:group_offer), 35.days.ago, 10.days.ago, started_within_end_after)
    started_after_no_end = create :volunteer
    create_group_assignments(create(:group_offer), 10.days.ago, nil, started_after_no_end)
    started_before_ended_before = create :volunteer
    create_group_assignments(create(:group_offer), 100.days.ago, 50.days.ago, started_before_ended_before)
    started_before_end_within = create :volunteer
    create_group_assignments(create(:group_offer), 100.days.ago, 35.days.ago, started_before_end_within)
    started_after_end_after = create :volunteer
    create_group_assignments(create(:group_offer), 10.days.ago, 5.days.ago, started_after_end_after)
    started_within_end_within = create :volunteer
    create_group_assignments(create(:group_offer), 39.days.ago, 31.days.ago, started_within_end_within)

    query = Volunteer.with_active_group_assignments_between(40.days.ago, 30.days.ago)
    assert query.include? started_before_end_after
    assert query.include? started_before_no_end
    assert query.include? started_within_end_after
    refute query.include? started_after_no_end
    refute query.include? started_before_ended_before
    assert query.include? started_before_end_within
    refute query.include? started_after_end_after
    assert query.include? started_within_end_within
  end

  test 'without_group_offer' do
    with_active = create :volunteer,
      group_assignments: [
        GroupAssignment.create(group_offer: create(:group_offer, active: true))
      ]
    with_archived = create :volunteer,
      group_assignments: [
        GroupAssignment.create(group_offer: create(:group_offer, active: false))
      ]
    with_active_and_archived = create :volunteer,
      group_assignments: [
        GroupAssignment.create(group_offer: create(:group_offer, active: true)),
        GroupAssignment.create(group_offer: create(:group_offer, active: false))
      ]
    without_group_offers = create :volunteer
    query = Volunteer.without_group_offer
    refute query.include? with_active
    refute query.include? with_active_and_archived
    refute query.include? with_archived
    assert query.include? without_group_offers
  end

  test 'external' do
    external = create :volunteer, external: true
    internal = create :volunteer, external: false
    query = Volunteer.external
    assert query.include? external
    refute query.include? internal
  end

  test 'internal' do
    external = create :volunteer, external: true
    internal = create :volunteer, external: false
    query = Volunteer.internal
    refute query.include? external
    assert query.include? internal
  end

  test 'with_assignment_6_months_ago' do
    started_before_no_end = create :volunteer
    make_assignment(start_date: 10.months.ago, volunteer: started_before_no_end)
    started_before_end_after = create :volunteer
    make_assignment(start_date: 10.months.ago, end_date: 2.months.ago,
      volunteer: started_before_end_after)
    started_after_no_end = create :volunteer
    make_assignment(start_date: 2.months.ago, volunteer: started_after_no_end)
    no_start_end_set = create :volunteer
    make_assignment(volunteer: no_start_end_set)
    no_assignment = create :volunteer
    query = Volunteer.with_assignment_6_months_ago
    assert query.include? started_before_no_end
    assert query.include? started_before_end_after
    refute query.include? started_after_no_end
    refute query.include? no_start_end_set
    refute query.include? no_assignment
  end

  test 'active_only_returns_accepted_volunteers_that_have_an_active_assignment' do
    volunteer_will_inactive = make_volunteer nil
    make_assignment(volunteer: volunteer_will_inactive, start_date: 10.days.ago,
      end_date: @today + 1)
    query = Volunteer.active
    assert query.include? volunteer_will_inactive
    assert query.include? @has_assignment
    assert query.include? @has_multiple
    assert query.include? @has_active_and_inactive
    refute query.include? @has_inactive
    refute query.include? @resigned_inactive
    refute query.include? @resigned_active
    travel_to(@today + 2)
    query = Volunteer.active
    refute query.include? volunteer_will_inactive
  end
end
