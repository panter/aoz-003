require 'test_helper'

class HourTest < ActiveSupport::TestCase
  test 'hour can only be valid with hourable relation' do
    assignment = create :assignment, volunteer: create(:volunteer)
    hour = Hour.new(volunteer: assignment.volunteer, hours: 1, meeting_date: 10.days.ago)
    refute hour.valid?
    assert_equal ['darf nicht leer sein'], hour.errors.messages[:hourable]
    hour.hourable = assignment
    assert hour.valid?
  end

  test 'semester returns hours for a billing_expense semester' do
    travel_to time_z(2018, 5, 25)
    assignment = create :assignment
    hours = {
      this_hour1: hour_for_meeting_date(time_z(2016, 12, 1), assignment),
      this_hour2: hour_for_meeting_date(time_z(2017, 4, 10), assignment),
      this_hour3: hour_for_meeting_date(time_z(2017, 5, 31), assignment),
      prev_hour1: hour_for_meeting_date(time_z(2016, 11, 15), assignment),
      prev_hour2: hour_for_meeting_date(time_z(2016, 10, 1), assignment),
      prev_hour3: hour_for_meeting_date(time_z(2016, 7, 1), assignment),
      two_prev_hour1: hour_for_meeting_date(time_z(2015, 12, 1), assignment),
      two_prev_hour2: hour_for_meeting_date(time_z(2016, 4, 10), assignment),
      two_prev_hour3: hour_for_meeting_date(time_z(2016, 5, 31), assignment),
      other_hour: hour_for_meeting_date(time_z(2013, 11, 21), assignment)
    }

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

  def hour_for_meeting_date(meeting_date, assignment)
    create :hour, volunteer: assignment.volunteer, hours: 1, meeting_date: meeting_date,
      hourable: assignment
  end
end
