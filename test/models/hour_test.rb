require 'test_helper'

class HourTest < ActiveSupport::TestCase
  include SemesterScopesGenerators

  test 'hour can only be valid with hourable relation' do
    assignment = create :assignment, volunteer: create(:volunteer)
    hour = Hour.new(volunteer: assignment.volunteer, hours: 1, meeting_date: 10.days.ago)
    refute hour.valid?
    assert_equal ['darf nicht leer sein'], hour.errors.messages[:hourable]
    hour.hourable = assignment
    assert hour.valid?
  end

  test 'semester returns hours for a billing_expense semester' do
    travel_to time_z(2013, 8, 1)
    assignment = create :assignment
    hours = {
      other_hour: hour_for_meeting_date(time_z(2013, 11, 21), assignment)
    }
    travel_to time_z(2015, 12, 1)
    hours = hours.merge(
      two_prev_hour1: hour_for_meeting_date(time_z(2015, 12, 1), assignment)
    )
    travel_to time_z(2016, 12, 1)
    hours = hours.merge(
      this_hour1: hour_for_meeting_date(time_z(2016, 12, 1), assignment),
      prev_hour1: hour_for_meeting_date(time_z(2016, 11, 29), assignment),
      prev_hour2: hour_for_meeting_date(time_z(2016, 10, 1), assignment),
      prev_hour3: hour_for_meeting_date(time_z(2016, 6, 1), assignment),
      two_prev_hour2: hour_for_meeting_date(time_z(2016, 4, 10), assignment),
      two_prev_hour3: hour_for_meeting_date(time_z(2016, 5, 30), assignment)
    )
    travel_to time_z(2017, 5, 1)
    hours = hours.merge(
      this_hour2: hour_for_meeting_date(time_z(2017, 4, 10), assignment),
      this_hour3: hour_for_meeting_date(time_z(2017, 5, 31), assignment)
    )
    travel_to time_z(2018, 5, 25)

    current_semester_hours = Hour.semester '2016-12-01'
    last_semester_hours = Hour.semester '2016-06-01'
    last_first_semester_hours = Hour.semester '2015-12-01'
    all_semester_hours = Hour.semester

    assert_includes current_semester_hours, hours[:this_hour1]
    assert_includes current_semester_hours, hours[:this_hour2]
    assert_includes current_semester_hours, hours[:this_hour3]
    assert_not_includes current_semester_hours, hours[:prev_hour1]
    assert_not_includes current_semester_hours, hours[:prev_hour2]
    assert_not_includes current_semester_hours, hours[:prev_hour3]
    assert_not_includes current_semester_hours, hours[:two_prev_hour1]
    assert_not_includes current_semester_hours, hours[:two_prev_hour2]
    assert_not_includes current_semester_hours, hours[:two_prev_hour3]
    assert_not_includes current_semester_hours, hours[:other_hour]

    assert_not_includes last_semester_hours, hours[:this_hour1]
    assert_not_includes last_semester_hours, hours[:this_hour2]
    assert_not_includes last_semester_hours, hours[:this_hour3]
    assert_includes last_semester_hours, hours[:prev_hour1]
    assert_includes last_semester_hours, hours[:prev_hour2]
    assert_includes last_semester_hours, hours[:prev_hour3]
    assert_not_includes last_semester_hours, hours[:two_prev_hour1]
    assert_not_includes last_semester_hours, hours[:two_prev_hour2]
    assert_not_includes last_semester_hours, hours[:two_prev_hour3]
    assert_not_includes last_semester_hours, hours[:other_hour]

    assert_not_includes last_first_semester_hours, hours[:this_hour1]
    assert_not_includes last_first_semester_hours, hours[:this_hour2]
    assert_not_includes last_first_semester_hours, hours[:this_hour3]
    assert_not_includes last_first_semester_hours, hours[:prev_hour1]
    assert_not_includes last_first_semester_hours, hours[:prev_hour2]
    assert_not_includes last_first_semester_hours, hours[:prev_hour3]
    assert_includes last_first_semester_hours, hours[:two_prev_hour1]
    assert_includes last_first_semester_hours, hours[:two_prev_hour2]
    assert_includes last_first_semester_hours, hours[:two_prev_hour3]
    assert_not_includes last_first_semester_hours, hours[:other_hour]

    hours.values.each do |hour|
      assert_includes all_semester_hours, hour
    end
  end
end
