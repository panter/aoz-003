require 'test_helper'

class ReminderMailingVolunteerTest < ActiveSupport::TestCase
  def setup
    @superadmin = create :user
    @volunteer = create :volunteer_with_user
    @assignment_probation = create :assignment, period_start: 7.weeks.ago, volunteer: @volunteer
  end

  test 'template variables are substituted' do
    reminder_mailing = ReminderMailing.new(kind: :trial_period, creator: @superadmin,
      subject: 'hallo %{Anrede} %{Name}', reminder_mailing_volunteers: [@assignment_probation],
      body: 'hallo %{Anrede} %{Name} %{EinsatzStart} %{Einsatz} %{EmailAbsender}')
    reminder_mailing.save
    mailing_volunteer = reminder_mailing.reminder_mailing_volunteers.first
    assert mailing_volunteer.process_template[:body].include? @volunteer.contact.natural_name
    assert mailing_volunteer.process_template[:subject].include?(
      I18n.t("salutation.#{@volunteer.salutation}")
    )
    assert mailing_volunteer.process_template[:body].include?(
      I18n.l(@assignment_probation.period_start)
    )
    assert mailing_volunteer.process_template[:body].include?(
      'Tandem mit ' +
      reminder_mailing.reminder_mailing_volunteers.first.reminder_mailable.client.contact
        .natural_name
    )
    assert mailing_volunteer.process_template[:body].include?(
      "[#{reminder_mailing.creator.profile.contact.natural_name}](mailto:#{reminder_mailing.creator.email})"
    )
  end

  test 'wrong template variables used in template are dropped - no exeption is thrown' do
    reminder_mailing = ReminderMailing.new(kind: :trial_period, creator: @superadmin,
      subject: 'hallo %{Anrede} %{WrongVariableUsed} %{Name}',
      reminder_mailing_volunteers: [@assignment_probation],
      body: 'hallo %{Anrede} %{Name} %{EinsatzStart}  %{AlsoWrong} %{Einsatz}')
    reminder_mailing.save
    mailing_volunteer = reminder_mailing.reminder_mailing_volunteers.first
    assert mailing_volunteer.process_template[:body].include? @volunteer.contact.natural_name
    assert mailing_volunteer.process_template[:subject].include? @volunteer.contact.natural_name
  end

  test 'last_feedback' do
    reminder_mailing = create :reminder_mailing, created_at: 1.month.ago,
      reminder_mailing_volunteers: [@assignment_probation]
    rmv = reminder_mailing.reminder_mailing_volunteers.first
    other_volunteer = create(:volunteer)

    feedback = create :feedback, volunteer: @volunteer, author: @volunteer.user,
      created_at: 1.day.ago, feedbackable: @assignment_probation
    feedback_older = create :feedback, volunteer: @volunteer, author: @volunteer.user,
      created_at: 1.week.ago, feedbackable: @assignment_probation
    _feedback_other_author = create :feedback, volunteer: @volunteer, author: @superadmin,
      created_at: 1.hour.ago, feedbackable: @assignment_probation
    _feedback_other_volunteer = create :feedback,
      volunteer: other_volunteer, author: other_volunteer.user,
      created_at: 1.hour.ago, feedbackable: @assignment_probation

    assert_equal feedback, rmv.last_feedback

    feedback.destroy

    assert_equal feedback_older, rmv.last_feedback

    feedback_older.destroy

    assert_nil rmv.last_feedback
  end
end
