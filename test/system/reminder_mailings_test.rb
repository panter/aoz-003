require 'application_system_test_case'

class ReminderMailingsTest < ApplicationSystemTestCase
  def setup
    really_destroy_with_deleted(GroupAssignment, GroupOffer, Volunteer, Client, User)
    @superadmin = create :user
    @volunteer_assignment = create :volunteer
    @group_offer = create :group_offer
    @volunteer_group_offer = create :volunteer
  end

  test 'group_assignment_and_assignment_elegible_for_half_year_reminder_mailing_are_includable' do
    assignment = create :assignment, period_start: 6.months.ago, period_end: nil,
      volunteer: @volunteer_assignment
    group_assignment = GroupAssignment.create(volunteer: @volunteer_group_offer, period_end: nil,
      group_offer: @group_offer, period_start: 6.months.ago)
    create :email_template_half_year
    login_as @superadmin
    visit reminder_mailings_path
    page.find_all('a', text: 'Halbjahres Erinnerung erstellen').first.click
    assert page.has_link? assignment.to_label, href: assignment_path(assignment)
    assert page.has_link? assignment.volunteer.contact.full_name, href: volunteer_path(assignment.volunteer)
    assert page.has_link? group_assignment.volunteer.contact.full_name, href: volunteer_path(group_assignment.volunteer)

    assert page.has_link? group_assignment.to_label,
      href: group_offer_path(group_assignment.group_offer)

    # All checkboxes are not checked?
    refute page.find_all(
      'input[name^="reminder_mailing[reminder_mailing_volunteers_attributes]"]'
    ).reduce { |a, b| a.checked? || b.checked? }

    check 'Ausgewählt', match: :first

    # at least one checkbox is checked?
    assert any_checked?(
      'input[name^="reminder_mailing[reminder_mailing_volunteers_attributes]"]')
    # not all checkboxes are checked
    refute all_checked?(
      'input[name^="reminder_mailing[reminder_mailing_volunteers_attributes]"]')

    check 'table-row-select-all'

    # All checkboxes are checked
    assert all_checked?(
      'input[name^="reminder_mailing[reminder_mailing_volunteers_attributes]"]')

    fill_in 'Betreff', with: 'Erinnerung fuer %{Einsatz}'
    fill_in 'Text', with: 'Hallo %{Anrede} %{Name} %{EinsatzStart}'

    first('input[type="submit"]').click

    assert page.has_text? 'Erinnerungs-Mailing wurde erfolgreich erstellt.'
    assert page.has_text? 'Art Halbjährlich'
    assert page.has_text? 'Status Nicht versandt'

    assert(
      page.has_text?(@volunteer_assignment.reminder_mailing_volunteers.last.process_template[:subject]) ||
      page.has_text?(@volunteer_group_offer.reminder_mailing_volunteers.last.process_template[:subject])
    )

    assert(
      page.has_text?(@volunteer_assignment.reminder_mailing_volunteers.last.process_template[:body]) ||
      page.has_text?(@volunteer_group_offer.reminder_mailing_volunteers.last.process_template[:body])
    )

    assert page.has_link? @volunteer_assignment.contact.full_name,
      href: volunteer_path(@volunteer_assignment)
    assert page.has_link? assignment.to_label, href: assignment_path(assignment)
    assert page.has_link? @volunteer_group_offer.contact.full_name,
      href: volunteer_path(@volunteer_group_offer)
    assert page.has_link? group_assignment.group_offer.to_label,
      href: group_offer_path(group_assignment.group_offer)
    click_link 'Emails versenden'
    creator = ReminderMailing.order('created_at asc').last.creator
    assert page.has_link? creator.full_name

    first_mailing = ReminderMailing.created_desc.first
    assert page.has_text? "#{I18n.l(first_mailing.updated_at.to_date)} #{I18n.l(first_mailing.created_at.to_date)}"
  end

  test 'group_assignment_and_assignment_elegible_for_probation_reminder_mailing_are_includable' do
    assignment = create :assignment, period_start: 7.weeks.ago, period_end: nil,
      volunteer: @volunteer_assignment
    group_assignment = GroupAssignment.create(volunteer: @volunteer_group_offer, period_end: nil,
      group_offer: @group_offer, period_start: 7.weeks.ago.to_date)
    create :email_template_trial
    login_as @superadmin
    visit reminder_mailings_path
    page.find_all('a', text: 'Probezeit Erinnerung erstellen').first.click
    assert page.has_link? assignment.to_label, href: assignment_path(assignment)
    assert page.has_link? assignment.volunteer.contact.full_name, href: volunteer_path(assignment.volunteer)
    assert page.has_link? group_assignment.volunteer.contact.full_name, href: volunteer_path(group_assignment.volunteer)

    assert page.has_link? group_assignment.to_label,
      href: group_offer_path(group_assignment.group_offer)

    # All checkboxes are not checked?
    refute page.find_all(
      'input[name^="reminder_mailing[reminder_mailing_volunteers_attributes]"]'
    ).reduce { |a, b| a.checked? || b.checked? }

    check 'Ausgewählt', match: :first

    # at least one checkbox is checked?
    assert any_checked?(
      'input[name^="reminder_mailing[reminder_mailing_volunteers_attributes]"]')
    # not all checkboxes are checked
    refute all_checked?(
      'input[name^="reminder_mailing[reminder_mailing_volunteers_attributes]"]')

    check 'table-row-select-all'

    # All checkboxes are checked
    assert all_checked?(
      'input[name^="reminder_mailing[reminder_mailing_volunteers_attributes]"]')

    fill_in 'Betreff', with: 'Erinnerung fuer %{Einsatz}'
    fill_in 'Text', with: 'Hallo %{Anrede} %{Name} %{EinsatzStart}'

    first('input[type="submit"]').click

    assert page.has_text? 'Erinnerungs-Mailing wurde erfolgreich erstellt.'
    assert page.has_text? 'Art Probezeit'
    assert page.has_text? 'Status Nicht versandt'

    assert(
      page.has_text?(@volunteer_assignment.reminder_mailing_volunteers.last.process_template[:subject]) ||
      page.has_text?(@volunteer_group_offer.reminder_mailing_volunteers.last.process_template[:subject])
    )

    assert(
      page.has_text?(@volunteer_assignment.reminder_mailing_volunteers.last.process_template[:body]) ||
      page.has_text?(@volunteer_group_offer.reminder_mailing_volunteers.last.process_template[:body])
    )

    assert page.has_link? @volunteer_assignment.contact.full_name,
      href: volunteer_path(@volunteer_assignment)
    assert page.has_link? assignment.to_label, href: assignment_path(assignment)
    assert page.has_link? @volunteer_group_offer.contact.full_name,
      href: volunteer_path(@volunteer_group_offer)
    assert page.has_link? group_assignment.group_offer.to_label,
      href: group_offer_path(group_assignment.group_offer)
    click_link 'Emails versenden'
    creator = ReminderMailing.order('created_at asc').last.creator
    assert page.has_link? creator.full_name

    first_mailing = ReminderMailing.created_desc.first
    assert page.has_text? "#{I18n.l(first_mailing.updated_at.to_date)} #{I18n.l(first_mailing.created_at.to_date)}"
  end

  test 'assignment_elegible_for_termination_reminder_mailing_are_includable' do
    @assignment = create :assignment, period_start: 7.weeks.ago, period_end: nil,
      volunteer: @volunteer_assignment
    create :email_template_termination
    login_as @superadmin
    visit edit_assignment_path(@assignment)

    page.find('#assignment_period_end').click
    page.find('.month', text: 'Jan').click
    first('.day', exact_text: '17').click
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
    assert page.has_text? 'Art Beendigung'
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
    visit polymorphic_path([group_assignment, termination_reminder], action: :send_termination)

    assert page.has_text? 'Beendigungs-Email wird versendet.'

    termination_reminder.reload
    assert termination_reminder.sending_triggered, 'Sending on the mailer was not triggered'
    mailer = ActionMailer::Base.deliveries.last
    mail_body = mailer.text_part.body.encoded

    assert_equal "Beendigung Gruppenangebot #{group_offer.title} (#{group_offer.department})",
      mailer.subject
    assert_includes mail_body, "#{group_assignment.volunteer.contact.natural_name} Feedback Geben"
    assert_includes mail_body, "#{I18n.l group_assignment.period_start} Gruss, AOZ"
    assert_not_includes mailer.subject, '%{'
    assert_not_includes mail_body, '%{'
  end
end
