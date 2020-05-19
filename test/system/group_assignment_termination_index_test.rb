require 'application_system_test_case'

class GroupAssignmentTerminationIndexTest < ApplicationSystemTestCase
  setup do
    @superadmin = create :user
    @volunteer1 = create :volunteer
    @volunteer2 = create :volunteer
    @volunteer3 = create :volunteer
    @volunteer4 = create :volunteer

    @group_offer1 = create :group_offer
    @not_ended = create :group_assignment, group_offer: @group_offer1, volunteer: @volunteer1,
      period_start: 3.weeks.ago, period_end: nil
    @un_submitted = create :group_assignment, group_offer: @group_offer1, volunteer: @volunteer2,
      period_start: 3.weeks.ago, period_end: 2.days.ago, period_end_set_by: @superadmin
    @submitted = create :group_assignment, group_offer: @group_offer1, volunteer: @volunteer3,
      period_start: 3.weeks.ago, period_end: 2.days.ago,
      termination_submitted_at: 2.days.ago, termination_submitted_by: @volunteer3.user,
      period_end_set_by: @superadmin
    @verified = create :group_assignment, group_offer: @group_offer1, volunteer: @volunteer4,
      period_start: 3.weeks.ago, period_end: 2.days.ago,
      termination_submitted_at: 2.days.ago, termination_submitted_by: @volunteer4.user,
      period_end_set_by: @superadmin, termination_verified_at: 2.days.ago,
      termination_verified_by: @superadmin

    login_as @superadmin
  end

  def termination_index_table_text(group_assignment)
    row_text = "#{group_assignment.volunteer.contact.full_name} "\
        "#{group_assignment.title} #{I18n.l(group_assignment.period_start)} "
    row_text += I18n.l(group_assignment.period_end) if group_assignment.period_end.present?
    row_text
  end

  test 'visiting_termination_index_displays_correct_assignments' do
    visit group_offers_path
    click_link 'Beendete Einsätze'
    assert_text termination_index_table_text(@un_submitted)
    assert_text termination_index_table_text(@submitted)
    refute_text termination_index_table_text(@not_ended), wait: 0
    refute_text termination_index_table_text(@verified), wait: 0
  end

  test 'filtering_submitted_terminations' do
    visit terminated_index_group_assignments_path
    click_link 'Ende Bestätigt'
    click_link exact_text: 'Bestätigt'
    visit current_url
    assert_text termination_index_table_text(@submitted)
    refute_text termination_index_table_text(@un_submitted), wait: 0
  end

  test 'filtering_not_submitted_terminations' do
    visit terminated_index_group_assignments_path
    click_link 'Ende Bestätigt'
    click_link exact_text: 'Unbestätigt'
    visit current_url
    assert_text termination_index_table_text(@un_submitted)
    refute_text termination_index_table_text(@submitted), wait: 0
  end

  test 'filtering_for_only_verified' do
    visit terminated_index_group_assignments_path
    click_link 'Quittiert: Unquittiert'
    click_link exact_text: 'Quittiert'
    visit current_url
    assert_text termination_index_table_text(@verified)
    refute_text termination_index_table_text(@un_submitted), wait: 0
    refute_text termination_index_table_text(@submitted), wait: 0
  end

  test 'ended_assignment_can_be_verified' do
    visit group_offers_path
    click_link 'Beendete Einsätze'
    assert_text termination_index_table_text(@un_submitted)
    assert_text termination_index_table_text(@submitted)
    refute_text termination_index_table_text(@verified), wait: 0

    page.find_all('a', text: 'Beendigung Quittieren').first.click
    click_link 'Beendigung Quittieren'

    assert_text 'Beendete Freiwillige'
    refute_text termination_index_table_text(@un_submitted), wait: 0
    refute_text termination_index_table_text(@submitted), wait: 0
    refute_text termination_index_table_text(@verified), wait: 0
  end

  test 'clear_filter_link_is_working_correctly' do
    visit group_offers_path
    click_link 'Beendete Einsätze'

    click_link 'Quittiert: Unquittiert'
    click_link exact_text: 'Quittiert'

    click_link 'Ende Bestätigt'
    click_link exact_text: 'Bestätigt'

    assert_text termination_index_table_text(@verified)
    refute_text termination_index_table_text(@un_submitted), wait: 0
    refute_text termination_index_table_text(@submitted), wait: 0
    refute_text termination_index_table_text(@not_ended), wait: 0

    click_link 'Filter aufheben'

    assert_text termination_index_table_text(@un_submitted)
    assert_text termination_index_table_text(@submitted)
    refute_text termination_index_table_text(@not_ended), wait: 0
    assert_text termination_index_table_text(@verified)
  end

  test 'there_is_correct_links_to_the_termination_forms' do
    visit terminated_index_group_assignments_path
    assert page.has_link? 'Beendigungsformular', href: terminate_group_assignment_path(@un_submitted.id)
    assert page.has_link? 'Beendigungsformular', href: terminate_group_assignment_path(@submitted.id)
  end

  test 'there_is_correct_links_to_creating_certificates' do
    visit terminated_index_group_assignments_path
    assert page.has_link? 'Dossier Freiwillig Engagiert erstellen',
      href: new_volunteer_certificate_path(@submitted.volunteer.id)
    refute page.has_link? 'Dossier Freiwillig Engagiert erstellen',
      href: new_volunteer_certificate_path(@un_submitted.volunteer.id), wait: 0
  end

  test 'group_assignment_quittieren_creates_a_group_assignment_log_record_from_group_assignment' do
    visit terminated_index_group_assignments_path
    click_link 'Beendigung Quittieren', href: verify_termination_group_assignment_path(@submitted.id)
    assert_text 'Der Gruppeneinsatz wurde erfolgreich quittiert.'
    assert_equal @submitted, GroupAssignmentLog.find_by(group_assignment_id: @submitted.id).group_assignment
  end

  test 'there_is_correct_links_on_email_status_column' do
    create :email_template_termination
    visit terminated_index_group_assignments_path

    # GroupAssignment has an end-date, but no reminder mailing was created
    click_link 'Beendigungs Email erstellen',
      href: new_termination_group_assignment_reminder_mailings_path(@un_submitted)
    click_button 'Erstellen und Vorschau anzeigen'

    # GroupAssignment has an end-date, reminder mailing was created, but not sent
    visit terminated_index_group_assignments_path
    click_link 'Beendigungs Email senden', href: reminder_mailing_path(@un_submitted.reminder_mailings
      .termination.last)
    click_link 'Email versenden'
    assert_text 'Beendigungs-Email wird versendet.'

    # GroupAssignment has an end-date, reminder mailing was created and was sent
    visit terminated_index_group_assignments_path
    @un_submitted.reload
    assert page.has_link? 'Übermittelt am ',
      href: reminder_mailing_path(@un_submitted.reminder_mailings.termination.last)

    click_link 'Beendigung Quittieren', href: /group_assignments\/#{@un_submitted.id}\/verify_termination/
    assert_text 'Der Gruppeneinsatz wurde erfolgreich quittiert.'

    @un_submitted.reload

    visit terminated_index_group_assignments_path
    click_link 'Quittiert: Unquittiert'
    click_link exact_text: 'Quittiert'

    assert_text "Quittiert von #{@un_submitted.termination_verified_by.full_name} am"\
      " #{I18n.l(@un_submitted.termination_verified_at.to_date)}"
  end
end
