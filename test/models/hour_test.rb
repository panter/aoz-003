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
    travel_to Time.zone.parse('2018-05-25')
    volunteer = create :volunteer
    prev_hour1 = create :hour, volunteer: volunteer, hours: 1, meeting_date: Time.zone.parse('2016-11-15')
    prev_hour2 = create :hour, volunteer: volunteer, hours: 1, meeting_date: Time.zone.parse('2016-10-01')
    this_hour1 = create :hour, volunteer: volunteer, hours: 1, meeting_date: Time.zone.parse('2016-12-01')
    this_hour2 = create :hour, volunteer: volunteer, hours: 1, meeting_date: Time.zone.parse('2017-05-11')
    other_hour = create :hour, volunteer: volunteer, hours: 1, meeting_date: Time.zone.parse('2013-11-21')

    current_semester_hours = Hour.semester '2016-12-01'
    last_semester_hours = Hour.semester '2016-06-01'
    all_semester_hours = Hour.semester

    assert_includes current_semester_hours, this_hour1
    assert_includes current_semester_hours, this_hour2
    assert_not_includes current_semester_hours, prev_hour1
    assert_not_includes current_semester_hours, prev_hour2
    assert_not_includes current_semester_hours, other_hour

    assert_includes last_semester_hours, prev_hour1
    assert_includes last_semester_hours, prev_hour2
    assert_not_includes last_semester_hours, this_hour1
    assert_not_includes last_semester_hours, this_hour2
    assert_not_includes last_semester_hours, other_hour

    [prev_hour1, prev_hour2, this_hour1, this_hour2, other_hour].map do |hour|
      assert_includes all_semester_hours, hour
    end
  end
end
