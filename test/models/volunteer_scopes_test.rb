require 'test_helper'

class VolunteerScopesTest < ActiveSupport::TestCase
  def setup
    @today = Time.zone.today
    make_volunteer(:has_assignment)
    make_volunteer(:has_multiple)
    make_volunteer(:has_inactive)
    make_volunteer(:group_offer_member)
    make_volunteer(:has_active_and_inactive)
    make_volunteer(:no_assignment)
    make_volunteer(:active_will_take_more, take_more_assignments: true)
    make_volunteer(:inactive_will_take_more, take_more_assignments: true)
    make_volunteer(:resigned_inactive, acceptance: :resigned)
    make_volunteer(:resigned_active, acceptance: :resigned)
    group_offer = create :group_offer
    create :group_assignment, group_offer: group_offer, volunteer: @group_offer_member
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
    with_inactive = create :volunteer,
      group_assignments: [
        GroupAssignment.create(group_offer: create(:group_offer, active: false))
      ]
    with_active_and_inactive = create :volunteer,
      group_assignments: [
        GroupAssignment.create(group_offer: create(:group_offer, active: true)),
        GroupAssignment.create(group_offer: create(:group_offer, active: false))
      ]
    without_group_offers = create :volunteer
    query = Volunteer.without_group_offer
    refute query.include? with_active
    refute query.include? with_active_and_inactive
    refute query.include? with_inactive
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

  test 'with_assignment_ca_6_weeks_ago' do
    started_before_no_end = create :volunteer
    make_assignment(start_date: 9.weeks.ago, volunteer: started_before_no_end)
    started_before_end_after = create :volunteer
    make_assignment(start_date: 10.months.ago, end_date: Time.zone.today + 10,
      volunteer: started_before_end_after)
    started_five_weeks_ago = create :volunteer
    make_assignment(start_date: 5.weeks.ago, volunteer: started_five_weeks_ago)
    started_six_weeks_ago = create :volunteer
    make_assignment(start_date: 6.weeks.ago, volunteer: started_six_weeks_ago)
    started_seven_weeks_ago = create :volunteer
    make_assignment(start_date: 7.weeks.ago, volunteer: started_seven_weeks_ago)
    started_eight_weeks_ago = create :volunteer
    make_assignment(start_date: 8.weeks.ago, volunteer: started_eight_weeks_ago)
    no_start_end_set = create :volunteer
    make_assignment(volunteer: no_start_end_set)
    no_assignment = create :volunteer

    query = Volunteer.with_assignment_ca_6_weeks_ago
    refute query.include? started_before_no_end
    refute query.include? started_before_end_after
    refute query.include? started_five_weeks_ago
    assert query.include? started_six_weeks_ago
    assert query.include? started_seven_weeks_ago
    assert query.include? started_eight_weeks_ago
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

  test 'with_billable_hours returns volunteers with billable hours for an optional semester' do
    travel_to tz_parse('2017-07-01')
    volunteers_in_current_semester_assertion = [@group_offer_member, @has_assignments]
    volunteers_in_last_semester_assertion    = [@has_multiple, @has_active_and_inactive]

    volunteers_in_current_semester_assertion.each do |volunteer|
      create :hour, hours: 1, volunteer: volunteer, meeting_date: tz_parse('2017-01-01')
      create :hour, hours: 2, volunteer: volunteer, meeting_date: tz_parse('2017-02-02')
    end

    volunteers_in_last_semester_assertion.each do |volunteer|
      create :hour, hours: 3, volunteer: volunteer, meeting_date: tz_parse('2016-09-01')
      create :hour, hours: 4, volunteer: volunteer, meeting_date: tz_parse('2016-11-11')
    end

    volunteers_with_billable_hours = Volunteer.with_billable_hours
    volunteers_in_current_semester = Volunteer.with_billable_hours '2016-12-01'
    volunteers_in_last_semester = Volunteer.with_billable_hours '2016-06-01'

    (volunteers_in_current_semester + volunteers_in_last_semester).each do |volunteer|
      assert_includes volunteers_with_billable_hours, volunteer
    end

    volunteers_in_current_semester.each do |volunteer|
      assert_includes volunteers_in_current_semester, volunteer
    end

    volunteers_in_last_semester.each do |volunteer|
      assert_not_includes volunteers_in_current_semester, volunteer
    end

    volunteers_in_last_semester.each do |volunteer|
      assert_includes volunteers_in_last_semester, volunteer
    end

    volunteers_in_current_semester.each do |volunteer|
      assert_not_includes volunteers_in_last_semester, volunteer
    end
  end

  test 'allready_has_billing_expense_for_semester_adds_hours_in_semester_not_in_billing_list' do
    travel_to tz_parse('2017-07-05-30')
    volunteer = create :volunteer_with_user
    assignment = create :assignment, volunteer: volunteer
    creator = assignment.creator
    volunteer.reload
    hours_before = ['2017-01-10', '2017-04-08', '2017-05-20'].map.with_index do |date, index|
      create(:hour, volunteer: volunteer, hourable: assignment, meeting_date: tz_parse(date),
        hours: index + 1)
    end
    assert_includes Volunteer.with_billable_hours('2016-12-01'), volunteer
    assert_equal 6.0, Volunteer.with_billable_hours('2016-12-01').to_a.first.total_hours
    assert_equal 6, hours_before.map(&:hours).sum
    BillingExpense.create_for!(Volunteer.with_billable_hours('2016-12-01'), creator, '2016-12-01')
    assert Volunteer.with_billable_hours('2016-12-01').blank?
    hours_after = ['2017-01-11', '2017-04-09', '2017-05-21'].map.with_index do |date, index|
      create(:hour, volunteer: volunteer, hourable: assignment, meeting_date: tz_parse(date),
        hours: index + 1)
    end
    assert_not_includes Volunteer.with_billable_hours('2016-12-01'), volunteer
    assert_includes Volunteer.with_billable_hours, volunteer
  end

  test 'with_registered_user returns volunteers where password is set for user' do
    volunteer_without_user1 = create :volunteer, :external
    volunteer_without_user2 = create :volunteer, :external
    volunteer_with_user1 = create :volunteer_with_user
    volunteer_with_user2 = create :volunteer_with_user

    # faking user sign in by setting last_sign_in_at an arbitrary date
    volunteer_with_user1.user.update last_sign_in_at: Time.now
    volunteer_with_user2.user.update last_sign_in_at: Time.now

    assert_nil volunteer_without_user1.user
    assert_nil volunteer_without_user2.user
    assert volunteer_with_user1.user.present?
    assert volunteer_with_user2.user.present?

    volunteers_with_user = Volunteer.with_actively_registered_user

    assert_includes volunteers_with_user, volunteer_with_user1
    assert_includes volunteers_with_user, volunteer_with_user2
    assert_not_includes volunteers_with_user, volunteer_without_user1
    assert_not_includes volunteers_with_user, volunteer_without_user2
  end

  test 'process returns volunteers filtered by acceptance or account status' do
    # clean existing volunteers first created by setup
    Volunteer.destroy_all

    # load test data
    @volunteer_not_logged_in = Volunteer.create!(contact: create(:contact), acceptance: :accepted, salutation: :mrs)
    Volunteer.acceptance_collection.each do |acceptance|
      volunteer = create :volunteer, acceptance: acceptance
      instance_variable_set("@volunteer_#{acceptance}", volunteer)
    end

    # test volunteers by acceptance
    Volunteer.acceptance_collection.each do |acceptance|
      volunteer = instance_variable_get("@volunteer_#{acceptance}")
      volunteers = Volunteer.process_eq(acceptance)
      other_acceptances = Volunteer.acceptance_collection - [acceptance]

      assert_includes volunteers, volunteer

      other_acceptances.each do |acceptance|
        other_volunteer = instance_variable_get("@volunteer_#{acceptance}")
        assert_not_includes volunteers, other_volunteer
      end
    end

    # special case for volunteers whose haven't logged in
    @volunteer_not_logged_in.invite_user
    volunteers = Volunteer.process_eq('havent_logged_in')
    assert_includes volunteers, @volunteer_not_logged_in
  end
end
