require 'application_system_test_case'

class ReminderMailingsTestsTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @volunteer = create :volunteer_with_user
    @assignment_probation = create :assignment, period_start: 7.weeks.ago, period_end: nil,
      volunteer: @volunteer
    @group_offer = create :group_offer
    @group_assignment_probation = GroupAssignment.create(volunteer: @volunteer, period_end: nil,
      group_offer: @group_offer, period_start: 7.weeks.ago.to_date)
  end

  test 'group_assignment_and_assignment_elegible_for_reminder_mailing_are_includable' do
    login_as @superadmin
    visit reminder_mailings_path
    click_link 'Probezeit Errinnerung erstellen'
    assert page.has_text? @assignment_probation.to_label
    assert page.has_text? @group_assignment_probation.to_label
    assert page.has_link? 'Einsatz Info', href: assignment_path(@assignment_probation)
    assert page.has_link? 'Einsatz Info', href: group_offer_path(@group_assignment_probation.group_offer)

    # All checkboxes are not checked?
    assert_equal false, page.find_all(
      'input[name^="reminder_mailing[reminder_mailing_volunteers_attributes]"]'
    ).reduce { |a, b| a.checked? || b.checked? }

    find('td', text: @assignment_probation.to_label).click
    # at least one checkbox is checked?
    assert_equal true, page.find_all(
      'input[name^="reminder_mailing[reminder_mailing_volunteers_attributes]"]'
    ).reduce { |a, b| a.checked? || b.checked? }
    # not all checkboxes are checked
    assert_equal false, page.find_all(
      'input[name^="reminder_mailing[reminder_mailing_volunteers_attributes]"]'
    ).reduce { |a, b| a.checked? && b.checked? }
    find('input[name="select-all-mailings"]').click
    # All checkboxes are checked
    assert_equal true, page.find_all(
      'input[name^="reminder_mailing[reminder_mailing_volunteers_attributes]"]'
    ).reduce { |a, b| a.checked? && b.checked? }

    fill_in 'Subject', with: 'Errinnerung fuer %{Einsatz}'
    fill_in 'Body', with: 'Hallo %{Anrede} %{Name} %{EinsatzStart}'

    click_button 'Erstellen und Vorschau anzeigen'

    assert page.has_text? 'Reminder mailing was successfully created.'
    assert page.has_text? 'Art Probezeit'
    assert page.has_text? 'Status Nicht versandt'

    assert page.has_text?
  end
end
