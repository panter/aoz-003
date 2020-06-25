require 'test_helper'

class VolunteerWithBillableHoursTest < ActiveSupport::TestCase
  include SemesterScopesGenerators

  def setup
    @semester1_in17 = time_z(2016, 12, 1)
    @semester1_in17_end = time_z(2017, 5, 31)
    @semester2_in16 = time_z(2016, 6, 1)
    @semester2_in16_end = time_z(2016, 11, 30)
    @semester1_in16 = time_z(2015, 12, 1)
    @semester1_in16_end = time_z(2016, 5, 31)
    @assignment1 = create :assignment
    @volunteer1 = @assignment1.volunteer
    @assignment2 = create :assignment
    @volunteer2 = @assignment2.volunteer
    @assignment3 = create :assignment
    @volunteer3 = @assignment3.volunteer
    @assignment4 = create :assignment
    @volunteer4 = @assignment4.volunteer
    @hours = {
      assignment1: {
        this_hour1: hour_for_meeting_date(@semester1_in17, @assignment1, 1),
        this_hour2: hour_for_meeting_date(time_z(2017, 4, 10), @assignment1, 2),
        this_hour3: hour_for_meeting_date(@semester1_in17_end, @assignment1, 3),
        prev_hour1: hour_for_meeting_date(@semester2_in16, @assignment1, 5),
        prev_hour2: hour_for_meeting_date(time_z(2016, 10, 1), @assignment1, 7),
        prev_hour3: hour_for_meeting_date(@semester2_in16_end, @assignment1, 11),
        two_prev_hour1: hour_for_meeting_date(@semester1_in16, @assignment1, 13),
        two_prev_hour2: hour_for_meeting_date(time_z(2016, 4, 10), @assignment1, 17),
        two_prev_hour3: hour_for_meeting_date(@semester1_in16_end, @assignment1, 19),
        other_hour: hour_for_meeting_date(time_z(2013, 11, 21), @assignment1, 23)
      },
      assignment2: {
        prev_hour1: hour_for_meeting_date(@semester2_in16, @assignment2, 29),
        prev_hour2: hour_for_meeting_date(time_z(2016, 10, 1), @assignment2, 31),
        prev_hour3: hour_for_meeting_date(@semester2_in16_end, @assignment2, 37),
        two_prev_hour1: hour_for_meeting_date(@semester1_in16, @assignment2, 41),
        two_prev_hour2: hour_for_meeting_date(time_z(2016, 4, 10), @assignment2, 43),
        two_prev_hour3: hour_for_meeting_date(@semester1_in16_end, @assignment2, 47),
        other_hour: hour_for_meeting_date(time_z(2013, 11, 21), @assignment2, 53)
      },
      assignment3: {
        this_hour1: hour_for_meeting_date(@semester1_in17, @assignment3, 59),
        this_hour2: hour_for_meeting_date(time_z(2017, 4, 10), @assignment3, 61),
        this_hour3: hour_for_meeting_date(@semester1_in17_end, @assignment3, 67),
        two_prev_hour1: hour_for_meeting_date(@semester1_in16, @assignment3, 71),
        two_prev_hour2: hour_for_meeting_date(time_z(2016, 4, 10), @assignment3, 73),
        two_prev_hour3: hour_for_meeting_date(@semester1_in16_end, @assignment3, 79),
        other_hour: hour_for_meeting_date(time_z(2013, 11, 21), @assignment3, 83)
      },
      assignment4: {
        this_hour1: hour_for_meeting_date(@semester1_in17, @assignment4, 89),
        this_hour2: hour_for_meeting_date(time_z(2017, 4, 10), @assignment4, 97),
        this_hour3: hour_for_meeting_date(@semester1_in17_end, @assignment4, 101),
        prev_hour1: hour_for_meeting_date(@semester2_in16, @assignment4, 103),
        prev_hour2: hour_for_meeting_date(time_z(2016, 10, 1), @assignment4, 107),
        prev_hour3: hour_for_meeting_date(@semester2_in16_end, @assignment4, 109),
        other_hour: hour_for_meeting_date(time_z(2013, 11, 21), @assignment4, 113)
      }
    }
  end

  test 'this_semester_volunteer_with_billable_hours' do
    skip 'tests have been commented out a year ago, and there has been a patch written now. These tests are to be re-enabled and fixed in one week'
    this_semester_billable = Volunteer.with_billable_hours(@semester1_in17.strftime('%Y-%m-%d'))

    volunteer1_in_result = find_volunteer_in_collection(this_semester_billable, @volunteer1)
    volunteer3_in_result = find_volunteer_in_collection(this_semester_billable, @volunteer3)
    volunteer4_in_result = find_volunteer_in_collection(this_semester_billable, @volunteer4)

    assert_includes this_semester_billable, @volunteer1
    assert_equal 6.0, volunteer1_in_result.last
    assert_includes this_semester_billable, @volunteer3
    assert_equal 187.0, volunteer3_in_result.last
    assert_includes this_semester_billable, @volunteer4
    assert_equal 287.0, volunteer4_in_result.last

    assert_not_includes this_semester_billable, @volunteer2
  end

  test 'previous_semester_volunteer_with_billable_hours' do
    skip 'tests have been commented out a year ago, and there has been a patch written now. These tests are to be re-enabled and fixed in one week'
    prev_semester_billable = Volunteer.with_billable_hours(@semester2_in16.strftime('%Y-%m-%d'))

    volunteer1_in_result = find_volunteer_in_collection(prev_semester_billable, @volunteer1)
    volunteer2_in_result = find_volunteer_in_collection(prev_semester_billable, @volunteer2)
    volunteer4_in_result = find_volunteer_in_collection(prev_semester_billable, @volunteer4)

    assert_includes prev_semester_billable, @volunteer1
    assert_equal 23.0, volunteer1_in_result.total_hours
    assert_includes prev_semester_billable, @volunteer2
    assert_equal 97.0, volunteer2_in_result.total_hours
    assert_includes prev_semester_billable, @volunteer4
    assert_equal 319.0, volunteer4_in_result.total_hours

    assert_not_includes prev_semester_billable, @volunteer3
  end

  test 'previous_first_semester_volunteer_with_billable_hours' do
    skip 'tests have been commented out a year ago, and there has been a patch written now. These tests are to be re-enabled and fixed in one week'
    two_prev_semester_billable = Volunteer.with_billable_hours(@semester1_in16.strftime('%Y-%m-%d'))

    volunteer1_in_result = find_volunteer_in_collection(two_prev_semester_billable, @volunteer1)
    volunteer2_in_result = find_volunteer_in_collection(two_prev_semester_billable, @volunteer2)
    volunteer3_in_result = find_volunteer_in_collection(two_prev_semester_billable, @volunteer3)

    assert_includes two_prev_semester_billable, @volunteer1
    assert_equal 49.0, volunteer1_in_result.total_hours
    assert_includes two_prev_semester_billable, @volunteer2
    assert_equal 131.0, volunteer2_in_result.total_hours
    assert_includes two_prev_semester_billable, @volunteer3
    assert_equal 223.0, volunteer3_in_result.total_hours

    assert_not_includes two_prev_semester_billable, @volunteer4
  end

  test 'all_semesters_volunteer_with_billable_hours' do
    skip 'tests have been commented out a year ago, and there has been a patch written now. These tests are to be re-enabled and fixed in one week'
    all_billable = Volunteer.with_billable_hours

    volunteer1_in_result = find_volunteer_in_collection(all_billable, @volunteer1)
    volunteer2_in_result = find_volunteer_in_collection(all_billable, @volunteer2)
    volunteer3_in_result = find_volunteer_in_collection(all_billable, @volunteer3)
    volunteer4_in_result = find_volunteer_in_collection(all_billable, @volunteer4)

    assert_includes all_billable, @volunteer1
    assert_equal 101.0, volunteer1_in_result.total_hours
    assert_includes all_billable, @volunteer2
    assert_equal 281.0, volunteer2_in_result.total_hours
    assert_includes all_billable, @volunteer3
    assert_equal 493.0, volunteer3_in_result.total_hours
    assert_includes all_billable, @volunteer4
    assert_equal 719.0, volunteer4_in_result.total_hours
  end

  test 'with_billed_hours_in_semester_added_new_not_apearing_in_this_semester' do
    skip 'tests have been commented out a year ago, and there has been a patch written now. These tests are to be re-enabled and fixed in one week'
    to_be_billed = Volunteer.with_billable_hours(@semester1_in17.strftime('%Y-%m-%d'))
      .where.not('volunteers.id = ?', @volunteer3.id)
    BillingExpense.create_for!(to_be_billed, create(:user), @semester1_in17.strftime('%Y-%m-%d'))

    before_added_hours = Volunteer.with_billable_hours(@semester1_in17.strftime('%Y-%m-%d'))

    assert_not_includes before_added_hours, @volunteer1
    assert_not_includes before_added_hours, @volunteer2
    assert_includes before_added_hours, @volunteer3
    assert_not_includes before_added_hours, @volunteer4

    hour_for_meeting_date(time_z(2017, 1, 12), @assignment1, 127)
    hour_for_meeting_date(time_z(2017, 1, 12), @assignment3, 131)

    after_added_hours = Volunteer.with_billable_hours(@semester1_in17.strftime('%Y-%m-%d'))

    assert_not_includes after_added_hours, @volunteer1
    assert_not_includes after_added_hours, @volunteer2
    assert_includes after_added_hours, @volunteer3
    assert_not_includes after_added_hours, @volunteer4
    assert_equal 318.0, find_volunteer_in_collection(after_added_hours, @volunteer3).total_hours
  end

  test 'with_billed_hours_in_semester_added_new_included_in_next_semester_scope' do
    skip 'tests have been commented out a year ago, and there has been a patch written now. These tests are to be re-enabled and fixed in one week'
    to_be_billed = Volunteer.with_billable_hours(@semester2_in16.strftime('%Y-%m-%d'))
    BillingExpense.create_for!(to_be_billed, create(:user), @semester2_in16.strftime('%Y-%m-%d'))

    previous_semester = Volunteer.with_billable_hours(@semester2_in16.strftime('%Y-%m-%d'))

    assert_not_includes previous_semester, @volunteer1
    assert_not_includes previous_semester, @volunteer2
    assert_not_includes previous_semester, @volunteer3
    assert_not_includes previous_semester, @volunteer4

    hour_for_meeting_date(time_z(2017, 1, 12), @assignment2, 127)

    this_semester = Volunteer.with_billable_hours(@semester1_in17.strftime('%Y-%m-%d'))

    volunteer1_in_result = find_volunteer_in_collection(this_semester, @volunteer1)
    volunteer2_in_result = find_volunteer_in_collection(this_semester, @volunteer2)
    volunteer3_in_result = find_volunteer_in_collection(this_semester, @volunteer3)
    volunteer4_in_result = find_volunteer_in_collection(this_semester, @volunteer4)

    assert_includes this_semester, @volunteer1
    assert_equal 6.0, volunteer1_in_result.total_hours
    assert_includes this_semester, @volunteer2
    assert_equal 127.0, volunteer2_in_result.total_hours
    assert_includes this_semester, @volunteer3
    assert_equal 187.0, volunteer3_in_result.total_hours
    assert_includes this_semester, @volunteer4
    assert_equal 287.0, volunteer4_in_result.total_hours
  end

  def find_volunteer_in_collection(result, searched_volunteer)
    result.find { |volunteer, hours, total_hours| volunteer == searched_volunteer }
  end
end
