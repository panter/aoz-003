require 'test_helper'

class VolunteerMailerTest < ActionMailer::TestCase
  def setup
    @volunteer = create :volunteer, education: 'Bogus Education', woman: true
    @email_template = create :email_template
  end

  test 'volunteer termination with confirmation data is sent correctly' do
    assignment = make_assignment(start_date: 8.months.ago, end_date: 2.days.ago)
    mailing = create_termination_mailing(assignment)
    mailing.reminder_mailing_volunteers do |rmv|
      mailer = VolunteerMailer.public_send(mailing.kind, rmv).deliver
      assert_equal rmv.process_template[:subject], mailer.subject
      assert_includes mailer.to, rmv.volunteer.contact.primary_email
      assert_match rmv.process_template[:body], mailer.body.encoded
    end
  end

  test 'send_group_assignment_termination_email_works_correctly' do
    group_assignment = create :group_assignment, period_start: 2.months.ago, period_end: 2.days.ago,
      period_end_set_by: @superadmin
    termination_reminder = create :reminder_mailing, kind: :termination,
      reminder_mailing_volunteers: [group_assignment],
      body: '%{Anrede} %{Name} %{FeedbackLink} %{Einsatz} %{EinsatzTitel} %{EmailAbsender} '\
            '%{EinsatzStart}'
    mailing_volunteer = termination_reminder.reminder_mailing_volunteers.first
    mailer = VolunteerMailer.public_send(termination_reminder.kind, mailing_volunteer).deliver
    assert_equal mailing_volunteer.process_template[:subject], mailer.subject
    assert_includes mailer.to, mailing_volunteer.volunteer.contact.primary_email
    assert_match mailing_volunteer.volunteer.contact.natural_name, mailer.body.encoded
    assert mailing_volunteer.email_sent,
           "email not marked sent on ReminderMailingVolunteer.id: #{mailing_volunteer.id}"
  end
end
