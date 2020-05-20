require 'test_helper'

class ReminderMailingVolunteerTest < ActiveSupport::TestCase
  def setup
    @superadmin = create :user
    @volunteer = create :volunteer
    @assignment_probation = create :assignment, period_start: 7.weeks.ago, volunteer: @volunteer
  end

  test 'template variables are substituted' do
    reminder_mailing = ReminderMailing.new(kind: :termination, creator: @superadmin,
      subject: 'hallo %{Anrede} %{Name}', reminder_mailing_volunteers: [@assignment_probation],
      body: 'hallo %{Anrede} %{Name} %{EinsatzStart} %{Einsatz} %{EmailAbsender}')
    reminder_mailing.save
    mailing_volunteer = reminder_mailing.reminder_mailing_volunteers.first
    assert_includes mailing_volunteer.process_template[:body], @volunteer.contact.natural_name
    assert_includes mailing_volunteer.process_template[:subject], I18n.t("salutation.#{@volunteer.salutation}")
    assert_includes mailing_volunteer.process_template[:body], I18n.l(@assignment_probation.period_start)
    assert_includes mailing_volunteer.process_template[:body], 'Tandem mit ' +
      reminder_mailing.reminder_mailing_volunteers.first.reminder_mailable.client.contact
      .natural_name
    assert_includes mailing_volunteer.process_template[:body], "[#{reminder_mailing.creator.profile.contact.natural_name}](mailto:#{reminder_mailing.creator.email})"
  end

  test 'wrong template variables used in template are dropped - no exeption is thrown' do
    reminder_mailing = ReminderMailing.new(kind: :termination, creator: @superadmin,
      subject: 'hallo %{Anrede} %{WrongVariableUsed} %{Name}',
      reminder_mailing_volunteers: [@assignment_probation],
      body: 'hallo %{Anrede} %{Name} %{EinsatzStart}  %{AlsoWrong} %{Einsatz}')
    reminder_mailing.save
    mailing_volunteer = reminder_mailing.reminder_mailing_volunteers.first
    assert_includes mailing_volunteer.process_template[:body], @volunteer.contact.natural_name
    assert_includes mailing_volunteer.process_template[:subject], @volunteer.contact.natural_name
  end

  test 'current_submission' do
    reminder_mailing = create :reminder_mailing, created_at: 1.month.ago,
      reminder_mailing_volunteers: [@assignment_probation]
    rmv = reminder_mailing.reminder_mailing_volunteers.first

    assert_nil rmv.current_submission

    @assignment_probation.update(submitted_at: 2.months.ago)
    assert_nil rmv.current_submission

    submitted_at = 1.day.ago
    @assignment_probation.update(submitted_at: submitted_at)
    assert_equal submitted_at, rmv.current_submission
  end

  test 'volunteer full_name' do
    reminder_mailing = create :reminder_mailing
    rmv = reminder_mailing.reminder_mailing_volunteers.first

    assert_equal rmv.full_name, rmv.volunteer.full_name
  end
end
