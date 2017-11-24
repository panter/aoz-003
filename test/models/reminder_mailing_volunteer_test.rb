require 'test_helper'

class ReminderMailingVolunteerTest < ActiveSupport::TestCase
  def setup
    @superadmin = create :user
    @volunteer = create :volunteer_with_user
    @assignment_probation = create :assignment, period_start: 7.weeks.ago, volunteer: @volunteer
  end

  test 'template variables are substituted' do
    reminder_mailing = ReminderMailing.new(kind: :probation_period, creator: @superadmin,
      subject: 'hallo %{Anrede} %{Name}', reminder_mailing_volunteers: [@assignment_probation],
      body: 'hallo %{Anrede} %{Name} %{EinsatzStart} %{Einsatz}')
    reminder_mailing.save
    mailing_volunteer = reminder_mailing.reminder_mailing_volunteers.first
    assert mailing_volunteer.process_template[:body].include? @volunteer.contact.full_name
    assert mailing_volunteer.process_template[:subject].include?(
      I18n.t("salutation.#{@volunteer.salutation}")
    )
    assert mailing_volunteer.process_template[:body].include?(
      I18n.l(@assignment_probation.period_start)
    )
    assert mailing_volunteer.process_template[:body].include? @assignment_probation.to_label
  end

  test 'selected_string_1_as_true_setter_works' do
    reminder_mailing = ReminderMailing.new(creator: @superadmin,
      reminder_mailing_volunteers: [@assignment_probation])
    mailing_volunteer = reminder_mailing.reminder_mailing_volunteers.first
    assert_not mailing_volunteer.selected
    mailing_volunteer.selected = '0'
    assert_equal false, mailing_volunteer.selected
    mailing_volunteer.selected = '1'
    assert_equal true, mailing_volunteer.selected
  end
end
