require 'test_helper'

class ReminderMailingTest < ActiveSupport::TestCase
  def setup
    @superadmin = create :user
    @volunteer = create :volunteer_with_user
    @assignment_probation = create :assignment, period_start: 7.weeks.ago, volunteer: @volunteer
    @group_offer = create :group_offer
    @group_assignment_probation = GroupAssignment.create(volunteer: @volunteer,
      group_offer: @group_offer, period_start: 6.weeks.ago.to_date + 2)
  end

  test 'reminder_mailing_has_right_relations' do
    reminder_mailing = ReminderMailing.new(kind: :probation_period, body: 'aaa',
      subject: 'aaa', creator: @superadmin, reminder_mailing_volunteers: [
        @assignment_probation, @group_assignment_probation
      ])
    # pretend to set form select value
    reminder_mailing.reminder_mailing_volunteers.each do |rmv|
      rmv.selected = '1'
    end
    reminder_mailing.save
    assert reminder_mailing.users.include? @volunteer.user
    assert reminder_mailing.volunteers.include? @volunteer
    assert reminder_mailing.assignments.include? @assignment_probation
    assert reminder_mailing.group_assignments.include? @group_assignment_probation
  end
end
