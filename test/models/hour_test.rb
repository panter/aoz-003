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

  test 'period returns hours for a billing_expense period' do
    current_period = BillingExpense::SEMESTER_LENGTH
    a_period_ago = current_period.ago
    last_period_ago = a_period_ago - BillingExpense::SEMESTER_LENGTH
    format = '%Y-%m-%d'

    volunteer = create :volunteer
    hour1 = create :hour, volunteer: volunteer, hours: 1, meeting_date: a_period_ago - 1.month
    hour2 = create :hour, volunteer: volunteer, hours: 1, meeting_date: a_period_ago - 2.months
    hour3 = create :hour, volunteer: volunteer, hours: 1, meeting_date: a_period_ago + 1.month
    hour4 = create :hour, volunteer: volunteer, hours: 1, meeting_date: a_period_ago + 2.months

    current_period_hours = Hour.period a_period_ago.strftime(format)
    last_period_hours = Hour.period last_period_ago.strftime(format)

    assert_includes current_period_hours, hour3
    assert_includes current_period_hours, hour4
    assert_not_includes current_period_hours, hour1
    assert_not_includes current_period_hours, hour2

    assert_includes last_period_hours, hour1
    assert_includes last_period_hours, hour2
    assert_not_includes last_period_hours, hour3
    assert_not_includes last_period_hours, hour4
  end
end
