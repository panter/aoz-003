require 'application_system_test_case'

class ReminderMailingsTest < ApplicationSystemTestCase
  def setup
    really_destroy_with_deleted(GroupAssignment, GroupOffer, Volunteer, Client, User)
    @superadmin = create :user
    @volunteer_assignment = create :volunteer_with_user
    @group_offer = create :group_offer
    @volunteer_group_offer = create :volunteer_with_user
    @volunteer_assignment.user.update(last_sign_in_at: Time.now)
    @volunteer_group_offer.user.update(last_sign_in_at: Time.now)
  end

  test 'assignment_elegible_for_termination_reminder_mailing_are_includable' do
    @assignment = create :assignment, period_start: 7.weeks.ago, period_end: nil,
      volunteer: @volunteer_assignment
    create :email_template_termination
    login_as @superadmin
    visit edit_assignment_path(@assignment)

    # this test will always need January 1st as date, else the test will fail
    # because ending an assignment will only redirect to terminated_index if
    # the date is in the past or current day
    # and the date selector chooses automatically current year
    page.find('#assignment_period_end').click
    page.find('.month', text: 'Jan').click
    first('.day', exact_text: '1').click
    page.find_all('input[type="submit"]').first.click

    assert page.has_current_path? terminated_index_assignments_path

    within '.table-responsive' do
      click_link 'Beendigungs Email erstellen', href: new_termination_assignment_reminder_mailings_path(@assignment)
    end

    assert page.has_link? @assignment.to_label, href: assignment_path(@assignment)
    assert page.has_link? @volunteer_assignment.contact.full_name, href: edit_volunteer_path(@volunteer_assignment)

    fill_in 'Betreff', with: 'Erinnerung fuer Beendigung des Einsatzes: %{Einsatz}'
    fill_in 'Text', with: 'Hallo %{Anrede} %{Name} %{EinsatzStart}'

    first('input[type="submit"]').click

    assert page.has_text? 'Erinnerungs-Mailing wurde erfolgreich erstellt.'
    assert page.has_text? 'Art Abschlussevaluation'
    assert page.has_text? 'Status Nicht versandt'

    assert page.has_text?(@volunteer_assignment.reminder_mailing_volunteers.first.process_template[:subject])
    assert page.has_text?(@volunteer_assignment.reminder_mailing_volunteers.last.process_template[:body])

    assert page.has_link? @volunteer_assignment.contact.full_name,
      href: volunteer_path(@volunteer_assignment)
    assert page.has_link? @assignment.to_label, href: assignment_path(@assignment)
    click_link 'Email versenden'
    creator = ReminderMailing.order('created_at asc').last.creator
    assert page.has_link? creator.full_name

    first_mailing = ReminderMailing.created_desc.first
    assert page.has_text? "#{I18n.l(first_mailing.updated_at.to_date)} #{I18n.l(first_mailing.created_at.to_date)}"
  end

  test 'termination_mailing_for_group_assignment_termination_is_sent' do
    group_assignment = create :group_assignment, period_start: 2.months.ago, period_end: 2.days.ago,
      period_end_set_by: @superadmin, volunteer: create(:volunteer)
    group_offer = group_assignment.group_offer

    termination_reminder = create :reminder_mailing, kind: :termination,
      reminder_mailing_volunteers: [group_assignment],
      subject: 'Beendigung %{Einsatz}',
      body: '%{Anrede} %{Name} %{FeedbackLink} %{Einsatz} %{EmailAbsender} '\
            '%{EinsatzStart} %{InvalidKey}Gruss, AOZ'
    login_as @superadmin

    # ignore invitation mails from factories
    ActionMailer::Base.deliveries.clear

    visit polymorphic_path([group_assignment, termination_reminder], action: :send_termination)

    assert page.has_text? 'Beendigungs-Email wird versendet.'

    termination_reminder.reload
    assert termination_reminder.sending_triggered, 'Sending on the mailer was not triggered'

    assert_equal 1, ActionMailer::Base.deliveries.size
    mailer = ActionMailer::Base.deliveries.last
    mail_body = mailer.text_part.body.encoded

    assert_equal "Beendigung Gruppenangebot #{group_offer.title} (#{group_offer.department})",
      mailer.subject

    assert_includes mail_body, "#{group_assignment.volunteer.contact.natural_name} Abschlussevaluations-Feedback erstellen"
    assert_includes mail_body, "#{I18n.l group_assignment.period_start} Gruss, AOZ"
    refute_includes mailer.subject, '%{'
    refute_includes mail_body, '%{'
  end

  test 'reminder_mailing_show_with_missing_reminder_mailing_volunteers_does_not_crash' do
    reminder_mailing = create :reminder_mailing
    assert_equal 1, reminder_mailing.reminder_mailing_volunteers.count
    rm_volunteer = reminder_mailing.reminder_mailing_volunteers.first
    login_as @superadmin
    visit reminder_mailing_path(reminder_mailing)
    rm_volunteer.really_destroy!
    reminder_mailing.reload
    assert_equal 0, reminder_mailing.reminder_mailing_volunteers.count
    visit reminder_mailing_path(reminder_mailing)
  end
end
