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
    travel_to Time.zone.parse('2014-05-12')
    a_semester_ago = BillingExpense::SEMESTER_LENGTH.ago
    last_semester_ago = a_semester_ago - BillingExpense::SEMESTER_LENGTH
    format = '%Y-%m-%d'

    volunteer = create :volunteer
    hour1 = create :hour, volunteer: volunteer, hours: 1, meeting_date: a_semester_ago - 1.month
    hour2 = create :hour, volunteer: volunteer, hours: 1, meeting_date: a_semester_ago - 2.months
    hour3 = create :hour, volunteer: volunteer, hours: 1, meeting_date: a_semester_ago + 1.month
    hour4 = create :hour, volunteer: volunteer, hours: 1, meeting_date: a_semester_ago + 2.months

    current_semester_hours = Hour.semester a_semester_ago.strftime(format)
    last_semester_hours = Hour.semester last_semester_ago.strftime(format)

    assert_includes current_semester_hours, hour3
    assert_includes current_semester_hours, hour4
    assert_not_includes current_semester_hours, hour1
    assert_not_includes current_semester_hours, hour2

    assert_includes last_semester_hours, hour1
    assert_includes last_semester_hours, hour2
    assert_not_includes last_semester_hours, hour3
    assert_not_includes last_semester_hours, hour4
  end
end
