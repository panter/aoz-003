require 'application_system_test_case'

class ReminderMailingsTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @volunteer = create :volunteer_with_user
    @assignment = create :assignment, period_start: 7.weeks.ago, period_end: nil,
      volunteer: @volunteer
    @group_offer = create :group_offer
    @group_assignment = GroupAssignment.create(volunteer: @volunteer, period_end: nil,
      group_offer: @group_offer, period_start: 7.weeks.ago.to_date)
    create :email_template_trial
  end

  test 'group_assignment_and_assignment_elegible_for_reminder_mailing_are_includable' do
    login_as @superadmin
    visit reminder_mailings_path
    page.find_all('a', text: 'Probezeit Errinnerung erstellen').first.click
    assert page.has_text? @assignment.to_label
    assert page.has_text? @group_assignment.to_label
    assert page.has_link? 'Einsatz Info', href: assignment_path(@assignment)
    assert page.has_link? 'Einsatz Info', href: group_offer_path(@group_assignment.group_offer)

    # All checkboxes are not checked?
    assert_equal false, page.find_all(
      'input[name^="reminder_mailing[reminder_mailing_volunteers_attributes]"]'
    ).reduce { |a, b| a.checked? || b.checked? }

    find('td', text: @assignment.to_label).click
    # at least one checkbox is checked?
    assert_equal true, any_checked?(
      'input[name^="reminder_mailing[reminder_mailing_volunteers_attributes]"]')
    # not all checkboxes are checked
    assert_equal false, all_checked?(
      'input[name^="reminder_mailing[reminder_mailing_volunteers_attributes]"]')
    find('input[name="select-all-mailings"]').click
    # All checkboxes are checked
    assert_equal true, all_checked?(
      'input[name^="reminder_mailing[reminder_mailing_volunteers_attributes]"]')

    fill_in 'Subject', with: 'Errinnerung fuer %{Einsatz}'
    fill_in 'Body', with: 'Hallo %{Anrede} %{Name} %{EinsatzStart}'

    page.find_all('input[type="submit"]').first.click

    assert page.has_text? 'Reminder mailing was successfully created.'
    assert page.has_text? 'Art Probezeit'
    assert page.has_text? 'Status Nicht versandt'

    assert(
      page.has_text?("Errinnerung fuer #{@assignment.to_label}") ||
      page.has_text?("Errinnerung fuer #{@group_offer.to_label}")
    )

    assert(
      page.has_text?(I18n.t("salutation.#{@assignment.volunteer.salutation}")) ||
      page.has_text?(I18n.t("salutation.#{@group_assignment.volunteer.salutation}"))
    )

    assert(
      page.has_text?(@assignment.volunteer.contact.natural_name) ||
      page.has_text?(@group_assignment.volunteer.contact.natural_name)
    )
    assert(
      page.has_text?(I18n.l(@assignment.period_start.to_date)) ||
      page.has_text?(I18n.l(@group_assignment.period_start.to_date))
    )

    assert page.has_link? @assignment.volunteer.contact.full_name,
      href: volunteer_path(@assignment.volunteer)
    assert page.has_link? @assignment.to_label, href: assignment_path(@assignment)
    assert page.has_link? @group_assignment.volunteer.contact.full_name,
      href: volunteer_path(@assignment.volunteer)
    assert page.has_link? @group_assignment.group_offer.to_label,
      href: group_offer_path(@group_assignment.group_offer)
    click_link 'Emails versenden'
    assert page.has_link? ReminderMailing.order('created_at asc').last.creator.to_label
    assert page.has_text? "Übermittelt #{I18n.l(ReminderMailing.order('created_at asc').last.created_at.to_date)}"
  end
end
