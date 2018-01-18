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
      I18n.t("salutation.#{@volunteer.salutation}", locale: :de)
    )
    assert mailing_volunteer.process_template[:body].include?(
      I18n.l(@assignment_probation.period_start, locale: :de)
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
end
