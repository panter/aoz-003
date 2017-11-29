require 'test_helper'

class ReminderTest < ActiveSupport::TestCase
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test 'create reminder by factory method' do
    @assignment = create(:assignment)
    @volunteer = @assignment.volunteer
    @email = @volunteer.contact.primary_email
    r = Reminder.create_for(@volunteer, @assignment)
    mailer = ReminderMailer.reminder_email(r).deliver
    assert_equal [@email], mailer.to
    assert_equal ['info@aoz-freiwillige.ch'], mailer.from
    assert_equal "Reports' confirmation", mailer.subject

    mail_body = mailer.body.encoded
    assert_match @volunteer.contact.first_name, mail_body
    assert_match @volunteer.contact.last_name, mail_body
    assert_match 'Please confirm the hour report and assignment journal for', mail_body
    assert_match @assignment.client.contact.full_name, mail_body

    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test 'creates batch reminders when criteria are met' do
    10.times do
      create :assignment, period_start: 10.months.ago, period_end: nil
    end
    Reminder.conditionally_create_reminders
    assert_equal 10, Reminder.count
    create :assignment, period_start: 1.month.ago, period_end: nil
    create :assignment, submitted_at: 1.month.ago
    create :assignment, state: 'suggested', period_start: nil, period_end: nil
    Reminder.conditionally_create_reminders
    assert_equal 10, Reminder.count
  end

  test 'reminders can only be created with internal volunteers' do
    assignment = create :assignment
    assignment.volunteer.update(external: true)
    assignment.reload
    reminder = build :reminder, volunteer: assignment.volunteer
    refute reminder.valid?
    assert reminder.errors.messages[:volunteer].include? 'external volunteers can not get reminders'
  end
end
