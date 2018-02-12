require 'test_helper'
require 'ostruct'
require 'utility/performance_report_generator'

class GroupOfferCategoryTest < ActiveSupport::TestCase
  include PerformanceReportGenerator

  def setup
    DatabaseCleaner.clean
    DatabaseCleaner.start

    really_destroy_with_deleted(Hour, Feedback, TrialFeedback, Assignment, Client, GroupAssignment,
      GroupOffer, Department, User)
    @today = Time.zone.today
    @this_periods = [@today.beginning_of_year, @today.end_of_year]
    @this_dates = @this_periods.map(&:to_date)
    @year_ago = 1.year.ago.to_date
    @last_periods = [@year_ago.beginning_of_year, @year_ago.end_of_year]
    @last_dates = @last_periods.map(&:to_date)
    @user = create :user

    @this_year = PerformanceReport.create!(user: @user, period_start: @this_periods.first,
      period_end: @this_periods.last)
    @last_year = PerformanceReport.create!(user: @user, period_start: @last_periods.first,
      period_end: @last_periods.last)
  end

  def refresh_reports
    @this_year.generate_report
    @last_year.generate_report
  end

  def type_of_values(content)
    content.values.flat_map(&:values).flat_map(&:values).uniq
  end

  test 'no_nothing_reports_have_all_zero_values' do
    assert_equal([0, 0.0], type_of_values(@this_year.report_content))
    assert_equal([0, 0.0], type_of_values(@last_year.report_content))
  end

  VOLUNTEER_ZERO = {
    total: 0,
    active_assignment: 0,
    active_group_assignment: 0,
    active_both: 0,
    active_total: 0,
    only_assignment_active: 0,
    only_group_active: 0,
    created: 0,
    resigned: 0,
    inactive: 0,
    assignment_hour_records: 0,
    assignment_hours: 0.0,
    group_offer_hour_records: 0,
    group_offer_hours: 0.0,
    total_hour_records: 0,
    total_hours: 0.0,
    assignment_feedbacks: 0,
    group_offer_feedbacks: 0,
    total_feedbacks: 0,
    assignment_trial_feedbacks: 0,
    group_offer_trial_feedbacks: 0,
    total_trial_feedbacks: 0
  }.stringify_keys.freeze

  test 'volunteer_zurich_internal_external' do
    volunteer_zurich_this_year = create :volunteer_with_user, :zuerich
    volunteer_zurich_this_year.update(created_at: @this_periods.first)

    # Last year still all zero
    refresh_reports
    assert_equal([0, 0.0], type_of_values(@last_year.report_content))

    # this year 0 and 1
    refresh_reports
    assert_equal([0, 0.0, 1], type_of_values(@this_year.report_content).sort)

    expected_influenced = VOLUNTEER_ZERO.merge(
      total: 1, created: 1, inactive: 1
    ).stringify_keys

    assert_equal(expected_influenced, @this_year.report_content['volunteers']['all'])
    assert_equal(expected_influenced, @this_year.report_content['volunteers']['zurich'])
    assert_equal(expected_influenced, @this_year.report_content['volunteers']['internal'])

    assert_equal([0, 0.0], @this_year.report_content['volunteers']['not_zurich'].values.uniq)
    assert_equal([0, 0.0], @this_year.report_content['volunteers']['external'].values.uniq)

    volunteer_zurich_this_year.update(external: true)
    refresh_reports
    assert_equal(expected_influenced, @this_year.report_content['volunteers']['all'])
    assert_equal(expected_influenced, @this_year.report_content['volunteers']['zurich'])
    assert_equal(expected_influenced, @this_year.report_content['volunteers']['external'])

    assert_equal([0, 0.0], @this_year.report_content['volunteers']['not_zurich'].values.uniq)
    assert_equal([0, 0.0], @this_year.report_content['volunteers']['internal'].values.uniq)

    volunteer_zurich_this_year.update(external: false)
    volunteer_zurich_this_year.contact.update(postal_code: 3000, city: 'Bern')
    refresh_reports
    assert_equal(expected_influenced, @this_year.report_content['volunteers']['all'])
    assert_equal(expected_influenced, @this_year.report_content['volunteers']['not_zurich'])
    assert_equal(expected_influenced, @this_year.report_content['volunteers']['internal'])

    assert_equal([0, 0.0], @this_year.report_content['volunteers']['zurich'].values.uniq)
    assert_equal([0, 0.0], @this_year.report_content['volunteers']['external'].values.uniq)
  end

  test 'volunteer_active_inactive' do
    volunteer_zurich_this_year = create :volunteer_with_user, :zuerich
    volunteer_zurich_this_year.update(created_at: @this_dates.first + 2)
    volunteer_zurich_last_year = create :volunteer_with_user, :zuerich
    volunteer_zurich_last_year.update(created_at: @last_dates.first + 10)

    refresh_reports
    assert_equal([0, 0.0, 1, 2], type_of_values(@this_year.report_content).sort)
    assert_equal([0, 0.0, 1], type_of_values(@last_year.report_content).sort)

    expected_influenced_last_year = VOLUNTEER_ZERO.merge(
      total: 1, created: 1, inactive: 1
    ).stringify_keys

    expected_influenced_this_year = VOLUNTEER_ZERO.merge(
      total: 2, created: 1, inactive: 2
    ).stringify_keys

    assert_equal(expected_influenced_this_year, @this_year.report_content['volunteers']['all'])
    assert_equal(expected_influenced_this_year, @this_year.report_content['volunteers']['zurich'])
    assert_equal(expected_influenced_this_year, @this_year.report_content['volunteers']['internal'])
    assert_equal([0, 0.0], @this_year.report_content['volunteers']['not_zurich'].values.uniq)
    assert_equal([0, 0.0], @this_year.report_content['volunteers']['external'].values.uniq)

    assert_equal(expected_influenced_last_year, @last_year.report_content['volunteers']['all'])
    assert_equal(expected_influenced_last_year, @last_year.report_content['volunteers']['zurich'])
    assert_equal(expected_influenced_last_year, @last_year.report_content['volunteers']['internal'])
    assert_equal([0, 0.0], @last_year.report_content['volunteers']['not_zurich'].values.uniq)
    assert_equal([0, 0.0], @last_year.report_content['volunteers']['external'].values.uniq)

    create(:assignment, volunteer: volunteer_zurich_this_year, period_start: 2.days.ago,
      period_end: nil)

    refresh_reports

    expected_influenced_this_year.merge!(
      active_assignment: 1, active_total: 1, only_assignment_active: 1, inactive: 1
    ).stringify_keys!

    assert_equal(expected_influenced_this_year, @this_year.report_content['volunteers']['all'])

    volunteer_zurich_this_year2 = create :volunteer_with_user, :zuerich
    volunteer_zurich_this_year2.update(created_at: @this_dates.first + 2)
    create(:group_assignment, volunteer: volunteer_zurich_this_year2, period_start: 2.days.ago,
      period_end: nil)

    expected_influenced_this_year.merge!(
      total: 3, active_group_assignment: 1, active_total: 2, only_group_active: 1, created: 2
    ).stringify_keys!
    refresh_reports

    assert_equal(expected_influenced_this_year, @this_year.report_content['volunteers']['all'])

    group_assignment_zh_this_year = create(:group_assignment, volunteer: volunteer_zurich_this_year,
      period_start: @this_periods.first, period_end: nil)
    last_year_assignment = create(:assignment, volunteer: volunteer_zurich_last_year,
      period_start: 1.year.ago, period_end: nil)

    expected_influenced_this_year.merge!(
      active_assignment: 2, active_group_assignment: 2, active_total: 3, active_both: 1, inactive: 0
    ).stringify_keys!
    expected_influenced_last_year.merge!(
      active_assignment: 1, active_total: 1, only_assignment_active: 1, inactive: 0
    ).stringify_keys!
    refresh_reports

    assert_equal(expected_influenced_this_year, @this_year.report_content['volunteers']['all'])
    assert_equal(expected_influenced_last_year, @last_year.report_content['volunteers']['all'])

    group_assignment_zh_this_year.update(period_end: 2.days.ago)
    last_year_assignment.update(period_end: @last_dates.last - 20)

    expected_influenced_this_year.merge!(
      active_assignment: 1, active_group_assignment: 2, active_total: 2, active_both: 1,
      inactive: 1, only_assignment_active: 0
    ).stringify_keys!
    refresh_reports

    assert_equal(expected_influenced_this_year, @this_year.report_content['volunteers']['all'])
    assert_equal(expected_influenced_last_year, @last_year.report_content['volunteers']['all'])
  end

  CLIENT_ZERO = {
    created: 0,
    active_assignment: 0,
    inactive: 0,
    total: 0,
    resigned: 0
  }.freeze

  test 'client_values' do
    client_zurich_this_year = create :client_z
    client_zurich_this_year.update(created_at: @this_dates.first + 2)
    client_zurich_last_year = create :client_z
    client_zurich_last_year.update(created_at: @last_dates.first + 10)

    client_this_year = create :client
    client_this_year.update(created_at: @this_dates.first + 2)
    client_last_year = create :client
    client_last_year.update(created_at: @last_dates.first + 10)

    refresh_reports

    assert_equal([0, 0.0, 1, 2, 4], type_of_values(@this_year.report_content).sort)
    expected_this_year_all = CLIENT_ZERO.merge(created: 2, inactive: 4, total: 4).stringify_keys
    assert_equal(expected_this_year_all, @this_year.report_content['clients']['all'])
    expected_this_year_zurich = CLIENT_ZERO.merge(created: 1, inactive: 2, total: 2).stringify_keys
    assert_equal(expected_this_year_zurich, @this_year.report_content['clients']['zurich'])
    expected_this_year_not_zurich = CLIENT_ZERO.merge(created: 1, inactive: 2, total: 2).stringify_keys
    assert_equal(expected_this_year_not_zurich, @this_year.report_content['clients']['not_zurich'])

    assert_equal([0, 0.0, 1, 2], type_of_values(@last_year.report_content).sort)
    expected_last_year_all = CLIENT_ZERO.merge(created: 2, inactive: 2, total: 2).stringify_keys
    assert_equal(expected_last_year_all, @last_year.report_content['clients']['all'])
    expected_last_year_zurich = CLIENT_ZERO.merge(created: 1, inactive: 1, total: 1).stringify_keys
    assert_equal(expected_last_year_zurich, @last_year.report_content['clients']['zurich'])
    expected_last_year_not_zurich = CLIENT_ZERO.merge(created: 1, inactive: 1, total: 1).stringify_keys
    assert_equal(expected_last_year_not_zurich, @last_year.report_content['clients']['not_zurich'])

    assignment_zurich_this_year = create(:assignment, client: client_zurich_this_year,
      period_start: @this_dates.first + 4, period_end: nil)

    refresh_reports

    expected_this_year_all.merge!(inactive: 3, active_assignment: 1).stringify_keys!
    assert_equal(expected_this_year_all, @this_year.report_content['clients']['all'])
    expected_this_year_zurich.merge!(inactive: 1, active_assignment: 1).stringify_keys!
    assert_equal(expected_this_year_zurich, @this_year.report_content['clients']['zurich'])

    assignment_this_year = create(:assignment, client: client_this_year,
      period_start: @this_dates.first + 4, period_end: nil)

    refresh_reports

    expected_this_year_all.merge!(inactive: 2, active_assignment: 2).stringify_keys!
    assert_equal(expected_this_year_all, @this_year.report_content['clients']['all'])
    assert_equal(expected_this_year_zurich, @this_year.report_content['clients']['zurich'])
    expected_this_year_not_zurich.merge!(inactive: 1, active_assignment: 1).stringify_keys!
    assert_equal(expected_this_year_not_zurich, @this_year.report_content['clients']['not_zurich'])


    assignment_zurich_last_year = create(:assignment, client: client_zurich_last_year,
      period_start: @last_dates.first + 4, period_end: nil)
    assignment_zurich_last_year.update(created_at: @last_dates.first + 4)

    refresh_reports

    expected_this_year_all.merge!(inactive: 1, active_assignment: 3).stringify_keys!
    assert_equal(expected_this_year_all, @this_year.report_content['clients']['all'])
    expected_this_year_zurich.merge!(inactive: 0, active_assignment: 2).stringify_keys!
    assert_equal(expected_this_year_zurich, @this_year.report_content['clients']['zurich'])

    expected_last_year_all.merge!(inactive: 1, active_assignment: 1).stringify_keys!
    assert_equal(expected_last_year_all, @last_year.report_content['clients']['all'])
    expected_last_year_zurich.merge!(inactive: 0, active_assignment: 1).stringify_keys!
    assert_equal(expected_last_year_zurich, @last_year.report_content['clients']['zurich'])

    assignment_last_year = create(:assignment, client: client_last_year,
      period_start: @last_dates.first + 4, period_end: nil)

    refresh_reports

    expected_this_year_all.merge!(inactive: 0, active_assignment: 4).stringify_keys!
    assert_equal(expected_this_year_all, @this_year.report_content['clients']['all'])
    assert_equal(expected_this_year_zurich, @this_year.report_content['clients']['zurich'])
    expected_this_year_not_zurich.merge!(inactive: 0, active_assignment: 2).stringify_keys!
    assert_equal(expected_this_year_not_zurich, @this_year.report_content['clients']['not_zurich'])

    expected_last_year_all.merge!(inactive: 0, active_assignment: 2).stringify_keys!
    assert_equal(expected_last_year_all, @last_year.report_content['clients']['all'])
    assert_equal(expected_last_year_zurich, @last_year.report_content['clients']['zurich'])
    expected_last_year_not_zurich.merge!(inactive: 0, active_assignment: 1).stringify_keys!
    assert_equal(expected_last_year_not_zurich, @last_year.report_content['clients']['not_zurich'])

    assignment_zurich_last_year.update(period_end_set_by: @user, period_end: @last_dates.last - 35,
      termination_submitted_by: assignment_zurich_last_year.volunteer.user,
      termination_submitted_at: @last_dates.last - 30, termination_verified_by: @user,
      termination_verified_at: @last_dates.last - 20)
    client_zurich_last_year.update(acceptance: :resigned)
    client_zurich_last_year.update(resigned_at: @last_dates.last - 10)

    refresh_reports

    expected_this_year_all.merge!(active_assignment: 3).stringify_keys!
    assert_equal(expected_this_year_all, @this_year.report_content['clients']['all'])
    expected_this_year_zurich.merge!(active_assignment: 1).stringify_keys!
    assert_equal(expected_this_year_zurich, @this_year.report_content['clients']['zurich'])

    expected_last_year_all.merge!(inactive: 0, active_assignment: 1, resigned: 1).stringify_keys!
    assert_equal(expected_last_year_all, @last_year.report_content['clients']['all'])
    expected_last_year_zurich.merge!(active_assignment: 0, resigned: 1).stringify_keys!
    assert_equal(expected_last_year_zurich, @last_year.report_content['clients']['zurich'])

    assignment_zurich_this_year.update(period_end_set_by: @user, period_end: 2.days.ago,
    termination_submitted_by: assignment_zurich_this_year.volunteer.user,
    termination_submitted_at: 2.days.ago, termination_verified_by: @user,
    termination_verified_at: 2.days.ago)
    client_zurich_this_year.update(acceptance: :resigned)
    client_zurich_this_year.update(resigned_at: 2.days.ago)

    refresh_reports

    expected_this_year_all.merge!(active_assignment: 2, resigned: 1).stringify_keys!
    assert_equal(expected_this_year_all, @this_year.report_content['clients']['all'])
    expected_this_year_zurich.merge!(active_assignment: 0, resigned: 1).stringify_keys!
    assert_equal(expected_this_year_zurich, @this_year.report_content['clients']['zurich'])
  end

  ASSIGNMENT_ZERO = {
    all: 0,
    created: 0,
    started: 0,
    active: 0,
    ended: 0,
    probations_ended: 0,
    performance_appraisal_reviews: 0,
    home_visits: 0,
    first_instruction_lessons: 0,
    progress_meetings: 0,
    termination_submitted: 0,
    termination_verified: 0,
    hour_report_count: 0,
    hours: 0.0,
    feedback_count: 0,
    trial_feedback_count: 0
  }.freeze

  test 'assignment_values' do
    refresh_reports
    assert_equal([0, 0.0], type_of_values(@this_year.report_content).sort)
    assert_equal([0, 0.0], type_of_values(@last_year.report_content).sort)

    client_zurich_this_year = create(:client_z)
    client_zurich_this_year.update(created_at: @this_dates.first + 10)
    client_this_year = create(:client)
    client_this_year.update(created_at: @this_dates.first + 10)
    client_zurich_last_year = create(:client_z)
    client_zurich_last_year.update(created_at: @last_dates.first + 10)
    client_last_year = create(:client)
    client_last_year.update(created_at: @last_dates.first + 10)

    ass_zurich_this_year = create(:assignment, client: client_zurich_this_year, period_start: nil,
      period_end: nil)
    ass_zurich_this_year.update(created_at: @this_dates.first + 10)
    ass_this_year = create(:assignment, client: client_this_year, period_start: nil,
      period_end: nil)
    ass_this_year.update(created_at: @this_dates.first + 10)
    ass_zurich_last_year = create(:assignment, client: client_zurich_last_year, period_start: nil,
      period_end: nil)
    ass_zurich_last_year.update(created_at: @last_dates.first + 10)
    ass_last_year = create(:assignment, client: client_last_year, period_start: nil,
      period_end: nil)
    ass_last_year.update(created_at: @last_dates.first + 10)

    refresh_reports

    this_year_all_expected = ASSIGNMENT_ZERO.merge(all: 4, created: 2).stringify_keys
    assert_equal(this_year_all_expected, @this_year.report_content['assignments']['all'])
    this_year_zurich_expected = ASSIGNMENT_ZERO.merge(all: 2, created: 1).stringify_keys
    assert_equal(this_year_zurich_expected, @this_year.report_content['assignments']['zurich'])
    this_year_not_zurich_expected = ASSIGNMENT_ZERO.merge(all: 2, created: 1).stringify_keys
    assert_equal(this_year_not_zurich_expected, @this_year.report_content['assignments']['not_zurich'])
    this_year_external_expected = ASSIGNMENT_ZERO.stringify_keys
    assert_equal(this_year_external_expected, @this_year.report_content['assignments']['external'])
    this_year_internal_expected = ASSIGNMENT_ZERO.merge(all: 4, created: 2).stringify_keys
    assert_equal(this_year_internal_expected, @this_year.report_content['assignments']['internal'])

    last_year_all_expected = ASSIGNMENT_ZERO.merge(all: 2, created: 2).stringify_keys
    assert_equal(last_year_all_expected, @last_year.report_content['assignments']['all'])
    last_year_zurich_expected = ASSIGNMENT_ZERO.merge(all: 1, created: 1).stringify_keys
    assert_equal(last_year_zurich_expected, @last_year.report_content['assignments']['zurich'])
    last_year_not_zurich_expected = ASSIGNMENT_ZERO.merge(all: 1, created: 1).stringify_keys
    assert_equal(last_year_not_zurich_expected, @last_year.report_content['assignments']['not_zurich'])
    last_year_external_expected = ASSIGNMENT_ZERO.stringify_keys
    assert_equal(last_year_external_expected, @last_year.report_content['assignments']['external'])
    last_year_internal_expected = ASSIGNMENT_ZERO.merge(all: 2, created: 2).stringify_keys
    assert_equal(last_year_internal_expected, @last_year.report_content['assignments']['internal'])

    # starting assignments
    ass_zurich_this_year.update(period_start: @this_dates.first + 20)
    ass_this_year.update(period_start: @this_dates.first + 20)
    ass_zurich_last_year.update(period_start: @last_dates.first + 20)
    ass_last_year.update(period_start: @last_dates.first + 20)

    refresh_reports

    this_year_all_expected.merge!(started: 2, active: 4).stringify_keys!
    assert_equal(this_year_all_expected, @this_year.report_content['assignments']['all'])
    this_year_zurich_expected.merge!(started: 1, active: 2).stringify_keys!
    assert_equal(this_year_zurich_expected, @this_year.report_content['assignments']['zurich'])
    this_year_not_zurich_expected.merge!(started: 1, active: 2).stringify_keys!
    assert_equal(this_year_not_zurich_expected, @this_year.report_content['assignments']['not_zurich'])
    assert_equal(this_year_external_expected, @this_year.report_content['assignments']['external'])

    last_year_all_expected.merge!(started: 2, active: 2).stringify_keys!
    assert_equal(last_year_all_expected, @last_year.report_content['assignments']['all'])
    last_year_zurich_expected.merge!(started: 1, active: 1).stringify_keys!
    assert_equal(last_year_zurich_expected, @last_year.report_content['assignments']['zurich'])
    last_year_not_zurich_expected.merge!(started: 1, active: 1).stringify_keys!
    assert_equal(last_year_not_zurich_expected, @last_year.report_content['assignments']['not_zurich'])
    assert_equal(last_year_external_expected, @last_year.report_content['assignments']['external'])

    # intermediate date counts
    aux_date = @this_dates.first + (20 + 6 * 7)
    ass_zurich_this_year.update(probation_period: aux_date, performance_appraisal_review: aux_date,
      home_visit: aux_date, first_instruction_lesson: aux_date, progress_meeting: aux_date)
    aux_date = @this_dates.first + (20 + 6 * 7)
    ass_this_year.update(probation_period: aux_date, performance_appraisal_review: aux_date,
      home_visit: aux_date, first_instruction_lesson: aux_date, progress_meeting: aux_date)
    aux_date = @last_dates.first + (20 + 6 * 7)
    ass_zurich_last_year.update(probation_period: aux_date, performance_appraisal_review: aux_date,
      home_visit: aux_date, first_instruction_lesson: aux_date, progress_meeting: aux_date)
    aux_date = @last_dates.first + (20 + 6 * 7)
    ass_last_year.update(probation_period: aux_date, performance_appraisal_review: aux_date,
      home_visit: aux_date, first_instruction_lesson: aux_date, progress_meeting: aux_date)

    refresh_reports

    this_year_all_expected.merge!(probations_ended: 2, performance_appraisal_reviews: 2,
      home_visits: 2, first_instruction_lessons: 2, progress_meetings: 2).stringify_keys!
    assert_equal(this_year_all_expected, @this_year.report_content['assignments']['all'])
    this_year_zurich_expected.merge!(probations_ended: 1, performance_appraisal_reviews: 1,
      home_visits: 1, first_instruction_lessons: 1, progress_meetings: 1).stringify_keys!
    assert_equal(this_year_zurich_expected, @this_year.report_content['assignments']['zurich'])
    this_year_not_zurich_expected.merge!(probations_ended: 1, performance_appraisal_reviews: 1,
      home_visits: 1, first_instruction_lessons: 1, progress_meetings: 1).stringify_keys!
    assert_equal(this_year_not_zurich_expected, @this_year.report_content['assignments']['not_zurich'])
    assert_equal(this_year_external_expected, @this_year.report_content['assignments']['external'])

    last_year_all_expected.merge!(probations_ended: 2, performance_appraisal_reviews: 2,
      home_visits: 2, first_instruction_lessons: 2, progress_meetings: 2).stringify_keys!
    assert_equal(last_year_all_expected, @last_year.report_content['assignments']['all'])
    last_year_zurich_expected.merge!(probations_ended: 1, performance_appraisal_reviews: 1,
      home_visits: 1, first_instruction_lessons: 1, progress_meetings: 1).stringify_keys!
    assert_equal(last_year_zurich_expected, @last_year.report_content['assignments']['zurich'])
    last_year_not_zurich_expected.merge!(probations_ended: 1, performance_appraisal_reviews: 1,
      home_visits: 1, first_instruction_lessons: 1, progress_meetings: 1).stringify_keys!
    assert_equal(last_year_not_zurich_expected, @last_year.report_content['assignments']['not_zurich'])
    assert_equal(last_year_external_expected, @last_year.report_content['assignments']['external'])

    # feedback and hour stuff
    trial_feedback_zurich_this_year = create(:trial_feedback,
      trial_feedbackable: ass_zurich_this_year, volunteer: ass_zurich_this_year.volunteer,
      author: ass_zurich_this_year.volunteer.user)
    trial_feedback_zurich_this_year.update(created_at: ass_zurich_this_year.period_start + (7 * 7))
    trial_feedback_this_year = create(:trial_feedback, trial_feedbackable: ass_this_year,
      volunteer: ass_this_year.volunteer, author: ass_this_year.volunteer.user)
    trial_feedback_this_year.update(created_at: ass_this_year.period_start + (7 * 7))
    trial_feedback_zurich_last_year = create(:trial_feedback,
      trial_feedbackable: ass_zurich_last_year, volunteer: ass_zurich_last_year.volunteer,
      author: ass_zurich_last_year.volunteer.user)
    trial_feedback_zurich_last_year.update(created_at: ass_zurich_last_year.period_start + (7 * 7))
    trial_feedback_last_year = create(:trial_feedback, trial_feedbackable: ass_last_year,
      volunteer: ass_last_year.volunteer, author: ass_last_year.volunteer.user)
    trial_feedback_last_year.update(created_at: ass_last_year.period_start + (7 * 7))

    feedback_zurich_this_year = create(:feedback, feedbackable: ass_zurich_this_year,
      volunteer: ass_zurich_this_year.volunteer, author: ass_zurich_this_year.volunteer.user)
    feedback_zurich_this_year.update(created_at: ass_zurich_this_year.period_start + 80)
    feedback_this_year = create(:feedback, feedbackable: ass_this_year,
      volunteer: ass_this_year.volunteer, author: ass_this_year.volunteer.user)
    feedback_this_year.update(created_at: ass_this_year.period_start + 80)
    feedback_zurich_last_year = create(:feedback, feedbackable: ass_zurich_last_year,
      volunteer: ass_zurich_last_year.volunteer, author: ass_zurich_last_year.volunteer.user)
    feedback_zurich_last_year.update(created_at: ass_zurich_last_year.period_start + 80)
    feedback_last_year = create(:feedback, feedbackable: ass_last_year,
      volunteer: ass_last_year.volunteer, author: ass_last_year.volunteer.user)
    feedback_last_year.update(created_at: ass_last_year.period_start + 80)

    hour_zurich_this_year = create(:hour, hourable: ass_zurich_this_year, hours: 2, minutes: 30,
      volunteer: ass_zurich_this_year.volunteer, meeting_date: ass_zurich_this_year.period_start + 78)
    hour_zurich_this_year.update(created_at: ass_zurich_this_year.period_start + 80)
    hour_this_year = create(:hour, hourable: ass_this_year, hours: 2, minutes: 30,
      volunteer: ass_this_year.volunteer, meeting_date: ass_this_year.period_start + 78)
    hour_this_year.update(created_at: ass_this_year.period_start + 80)
    hour_zurich_last_year = create(:hour, hourable: ass_zurich_last_year, hours: 2, minutes: 30,
      volunteer: ass_zurich_last_year.volunteer, meeting_date: ass_zurich_last_year.period_start + 78)
    hour_zurich_last_year.update(created_at: ass_zurich_last_year.period_start + 80)
    hour_last_year = create(:hour, hourable: ass_last_year, hours: 2, minutes: 30,
      volunteer: ass_last_year.volunteer, meeting_date: ass_last_year.period_start + 78)
    hour_last_year.update(created_at: ass_last_year.period_start + 80)

    refresh_reports

    this_year_all_expected.merge!(hour_report_count: 2, feedback_count: 2, trial_feedback_count: 2,
      hours: 5.0).stringify_keys!
    assert_equal(this_year_all_expected, @this_year.report_content['assignments']['all'])
    this_year_zurich_expected.merge!(hour_report_count: 1, feedback_count: 1, trial_feedback_count: 1,
      hours: 2.5).stringify_keys!
    assert_equal(this_year_zurich_expected, @this_year.report_content['assignments']['zurich'])
    this_year_not_zurich_expected.merge!(hour_report_count: 1, feedback_count: 1, trial_feedback_count: 1,
      hours: 2.5).stringify_keys!
    assert_equal(this_year_not_zurich_expected, @this_year.report_content['assignments']['not_zurich'])
    assert_equal(this_year_external_expected, @this_year.report_content['assignments']['external'])

    last_year_all_expected.merge!(hour_report_count: 2, feedback_count: 2, trial_feedback_count: 2,
      hours: 5.0).stringify_keys!
    assert_equal(last_year_all_expected, @last_year.report_content['assignments']['all'])
    last_year_zurich_expected.merge!(hour_report_count: 1, feedback_count: 1, trial_feedback_count: 1,
      hours: 2.5).stringify_keys!
    assert_equal(last_year_zurich_expected, @last_year.report_content['assignments']['zurich'])
    last_year_not_zurich_expected.merge!(hour_report_count: 1, feedback_count: 1, trial_feedback_count: 1,
      hours: 2.5).stringify_keys!
    assert_equal(last_year_not_zurich_expected, @last_year.report_content['assignments']['not_zurich'])
    assert_equal(last_year_external_expected, @last_year.report_content['assignments']['external'])

    # Ending assignments
    period_end = @this_dates.first + 150
    ass_zurich_this_year.update(period_end: period_end, period_end_set_by: @user,
      termination_submitted_at: period_end + 5,
      termination_submitted_by: ass_zurich_this_year.volunteer.user, termination_verified_by: @user,
      termination_verified_at: period_end + 10)
    period_end = @this_dates.first + 150
    ass_this_year.update(period_end: period_end, period_end_set_by: @user,
      termination_submitted_at: period_end + 5,
      termination_submitted_by: ass_this_year.volunteer.user, termination_verified_by: @user,
      termination_verified_at: period_end + 10)
    period_end = @last_dates.first + 150
    ass_zurich_last_year.update(period_end: period_end, period_end_set_by: @user,
      termination_submitted_at: period_end + 5,
      termination_submitted_by: ass_zurich_last_year.volunteer.user,
      termination_verified_by: @user, termination_verified_at: period_end + 10)
    period_end = @last_dates.first + 150
    ass_last_year.update(period_end: period_end, period_end_set_by: @user,
      termination_submitted_at: period_end + 5,
      termination_submitted_by: ass_last_year.volunteer.user, termination_verified_by: @user,
      termination_verified_at: period_end + 10)

    refresh_reports

    this_year_all_expected.merge!(ended: 2, active: 2, termination_submitted: 2,
      termination_verified: 2).stringify_keys!
    assert_equal(this_year_all_expected, @this_year.report_content['assignments']['all'])
    this_year_zurich_expected.merge!(ended: 1, active: 1, termination_submitted: 1,
      termination_verified: 1).stringify_keys!
    assert_equal(this_year_zurich_expected, @this_year.report_content['assignments']['zurich'])
    this_year_not_zurich_expected.merge!(ended: 1, active: 1, termination_submitted: 1,
      termination_verified: 1).stringify_keys!
    assert_equal(this_year_not_zurich_expected, @this_year.report_content['assignments']['not_zurich'])
    assert_equal(this_year_external_expected, @this_year.report_content['assignments']['external'])

    last_year_all_expected.merge!(ended: 2, active: 2, termination_submitted: 2,
      termination_verified: 2).stringify_keys!
    assert_equal(last_year_all_expected, @last_year.report_content['assignments']['all'])
    last_year_zurich_expected.merge!(ended: 1, active: 1, termination_submitted: 1,
      termination_verified: 1).stringify_keys!
    assert_equal(last_year_zurich_expected, @last_year.report_content['assignments']['zurich'])
    last_year_not_zurich_expected.merge!(ended: 1, active: 1, termination_submitted: 1,
      termination_verified: 1).stringify_keys!
    assert_equal(last_year_not_zurich_expected, @last_year.report_content['assignments']['not_zurich'])
    assert_equal(last_year_external_expected, @last_year.report_content['assignments']['external'])
  end

  GROUP_OFFER_ZERO = {
    all: 0,
    created: 0,
    ended: 0,
    termination_verified: 0,
    created_assignments: 0,
    started_assignments: 0,
    active_assignments: 0,
    ended_assignments: 0,
    total_assignments: 0,
    total_created_assignments: 0,
    total_started_assignments: 0,
    total_active_assignments: 0,
    total_ended_assignments: 0,
    hour_report_count: 0,
    hours: 0.0,
    feedback_count: 0
  }.freeze

  test 'group_offer_values' do
    refresh_reports
    assert_equal([0, 0.0], type_of_values(@this_year.report_content).sort)
    assert_equal([0, 0.0], type_of_values(@last_year.report_content).sort)

    go_this_year_in_dep = create(:group_offer, department: create(:department))
    go_this_year_in_dep.update(created_at: @this_dates.first + 10)
    go_this_year_not_in_dep = create(:group_offer, department_id: nil)
    go_this_year_not_in_dep.update(created_at: @this_dates.first + 10)
    go_last_year_in_dep = create(:group_offer, department: create(:department))
    go_last_year_in_dep.update(created_at: @last_dates.first + 10)
    go_last_year_not_in_dep = create(:group_offer, department_id: nil)
    go_last_year_not_in_dep.update(created_at: @last_dates.first + 10)

    refresh_reports

    this_year_all_expected = GROUP_OFFER_ZERO.merge(all: 4, created: 2).stringify_keys
    assert_equal(this_year_all_expected, @this_year.report_content['group_offers']['all'])
    this_year_in_dep_expected = GROUP_OFFER_ZERO.merge(all: 2, created: 1).stringify_keys
    assert_equal(this_year_in_dep_expected, @this_year.report_content['group_offers']['in_departments'])
    this_year_not_in_dep_expected = GROUP_OFFER_ZERO.merge(all: 2, created: 1).stringify_keys
    assert_equal(this_year_not_in_dep_expected, @this_year.report_content['group_offers']['outside_departments'])

    last_year_all_expected = GROUP_OFFER_ZERO.merge(all: 2, created: 2).stringify_keys
    assert_equal(last_year_all_expected, @last_year.report_content['group_offers']['all'])
    last_year_in_dep_expected = GROUP_OFFER_ZERO.merge(all: 1, created: 1).stringify_keys
    assert_equal(last_year_in_dep_expected, @last_year.report_content['group_offers']['in_departments'])
    last_year_not_in_dep_expected = GROUP_OFFER_ZERO.merge(all: 1, created: 1).stringify_keys
    assert_equal(last_year_not_in_dep_expected, @last_year.report_content['group_offers']['outside_departments'])

    # active assignment
    g_ass_this_year_in_dep = create(:group_assignment, group_offer: go_this_year_in_dep,
      period_start: go_this_year_in_dep.created_at.to_date + 10, period_end: nil)
    g_ass_this_year_in_dep.update(created_at: @this_dates.first + 8)
    g_ass_this_year_not_in_dep = create(:group_assignment, group_offer: go_this_year_not_in_dep,
      period_start: go_this_year_not_in_dep.created_at.to_date + 10, period_end: nil)
    g_ass_this_year_not_in_dep.update(created_at: @this_dates.first + 8)
    g_ass_last_year_in_dep = create(:group_assignment, group_offer: go_last_year_in_dep,
      period_start: go_last_year_in_dep.created_at.to_date + 10, period_end: nil)
    g_ass_last_year_in_dep.update(created_at: @last_dates.first + 8)
    g_ass_last_year_not_in_dep = create(:group_assignment, group_offer: go_last_year_not_in_dep,
      period_start: go_last_year_not_in_dep.created_at.to_date + 10, period_end: nil)
    g_ass_last_year_not_in_dep.update(created_at: @last_dates.first + 8)

    refresh_reports

    this_year_all_expected.merge!(
      created_assignments: 2, started_assignments: 2, active_assignments: 4, total_assignments: 4,
      total_created_assignments: 2, total_started_assignments: 2, total_active_assignments: 4
    ).stringify_keys!
    assert_equal(this_year_all_expected, @this_year.report_content['group_offers']['all'])
    this_year_not_in_dep_expected.merge!(
      created_assignments: 1, started_assignments: 1, active_assignments: 2, total_assignments: 2,
      total_created_assignments: 1, total_started_assignments: 1, total_active_assignments: 2
    ).stringify_keys!
    assert_equal(this_year_not_in_dep_expected, @this_year.report_content['group_offers']['in_departments'])
    this_year_in_dep_expected.merge!(
      created_assignments: 1, started_assignments: 1, active_assignments: 2, total_assignments: 2,
      total_created_assignments: 1, total_started_assignments: 1, total_active_assignments: 2
    ).stringify_keys!
    assert_equal(this_year_in_dep_expected, @this_year.report_content['group_offers']['outside_departments'])

    last_year_all_expected.merge!(
      created_assignments: 2, started_assignments: 2, active_assignments: 2, total_assignments: 2,
      total_created_assignments: 2, total_started_assignments: 2, total_active_assignments: 2
    ).stringify_keys!
    assert_equal(last_year_all_expected, @last_year.report_content['group_offers']['all'])
    last_year_not_in_dep_expected.merge!(
      created_assignments: 1, started_assignments: 1, active_assignments: 1, total_assignments: 1,
      total_created_assignments: 1, total_started_assignments: 1, total_active_assignments: 1
    ).stringify_keys!
    assert_equal(last_year_not_in_dep_expected, @last_year.report_content['group_offers']['in_departments'])
    last_year_in_dep_expected.merge!(
      created_assignments: 1, started_assignments: 1, active_assignments: 1, total_assignments: 1,
      total_created_assignments: 1, total_started_assignments: 1, total_active_assignments: 1
    ).stringify_keys!
    assert_equal(last_year_in_dep_expected, @last_year.report_content['group_offers']['outside_departments'])

    # ended group assignments
    g_ass_this_year_in_dep.update(period_end: g_ass_this_year_in_dep.period_start + 100,
      period_end_set_by: @user, termination_submitted_by: g_ass_this_year_in_dep.volunteer.user,
      termination_submitted_at: g_ass_this_year_in_dep.period_start + 110, termination_verified_by: @user,
      termination_verified_at: g_ass_this_year_in_dep.period_start + 120)
    g_ass_this_year_not_in_dep.update(period_end: g_ass_this_year_not_in_dep.period_start + 100,
      period_end_set_by: @user, termination_submitted_by: g_ass_this_year_not_in_dep.volunteer.user,
      termination_submitted_at: g_ass_this_year_not_in_dep.period_start + 110, termination_verified_by: @user,
      termination_verified_at: g_ass_this_year_not_in_dep.period_start + 120)
    g_ass_last_year_in_dep.update(period_end: g_ass_last_year_in_dep.period_start + 100,
      period_end_set_by: @user, termination_submitted_by: g_ass_last_year_in_dep.volunteer.user,
      termination_submitted_at: g_ass_last_year_in_dep.period_start + 110, termination_verified_by: @user,
      termination_verified_at: g_ass_last_year_in_dep.period_start + 120)
    g_ass_last_year_not_in_dep.update(period_end: g_ass_last_year_not_in_dep.period_start + 100,
      period_end_set_by: @user, termination_submitted_by: g_ass_last_year_not_in_dep.volunteer.user,
      termination_submitted_at: g_ass_last_year_not_in_dep.period_start + 110, termination_verified_by: @user,
      termination_verified_at: g_ass_last_year_not_in_dep.period_start + 120)

    refresh_reports

    this_year_all_expected.merge!(ended_assignments: 2, total_active_assignments: 2,
      total_ended_assignments: 2, active_assignments: 2).stringify_keys!
    assert_equal(this_year_all_expected, @this_year.report_content['group_offers']['all'])
    this_year_not_in_dep_expected.merge!(ended_assignments: 1, total_active_assignments: 1,
      total_ended_assignments: 1, active_assignments: 1).stringify_keys!
    assert_equal(this_year_not_in_dep_expected, @this_year.report_content['group_offers']['in_departments'])
    this_year_in_dep_expected.merge!(ended_assignments: 1, total_active_assignments: 1,
      total_ended_assignments: 1, active_assignments: 1).stringify_keys!
    assert_equal(this_year_in_dep_expected, @this_year.report_content['group_offers']['outside_departments'])

    last_year_all_expected.merge!(ended_assignments: 2, total_active_assignments: 2,
      total_ended_assignments: 2, active_assignments: 2).stringify_keys!
    assert_equal(last_year_all_expected, @last_year.report_content['group_offers']['all'])
    last_year_not_in_dep_expected.merge!(ended_assignments: 1, total_active_assignments: 1,
      total_ended_assignments: 1, active_assignments: 1).stringify_keys!
    assert_equal(last_year_not_in_dep_expected, @last_year.report_content['group_offers']['in_departments'])
    last_year_in_dep_expected.merge!(ended_assignments: 1, total_active_assignments: 1,
      total_ended_assignments: 1, active_assignments: 1).stringify_keys!
    assert_equal(last_year_in_dep_expected, @last_year.report_content['group_offers']['outside_departments'])
  end
end
