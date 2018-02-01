require 'application_system_test_case'

class GroupAssignmentTerminationIndexTest < ApplicationSystemTestCase
  setup do
    @superadmin = create :user
    @volunteer1 = create :volunteer_with_user
    @volunteer2 = create :volunteer_with_user
    @volunteer3 = create :volunteer_with_user
    @volunteer4 = create :volunteer_with_user

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
    click_link 'Beendete Begleitungen'
    assert page.has_text? termination_index_table_text(@un_submitted)
    assert page.has_text? termination_index_table_text(@submitted)
    refute page.has_text? termination_index_table_text(@not_ended)
    refute page.has_text? termination_index_table_text(@verified)
  end

  test 'filtering_submitted_terminations' do
    visit terminated_index_group_assignments_path(q: { termination_verified_by_id_null: 'true' })
    click_link 'Ende Bestätigt'
    click_link exact_text: 'Bestätigt'
    visit current_url
    refute page.has_text? termination_index_table_text(@un_submitted)
    assert page.has_text? termination_index_table_text(@submitted)
  end

  test 'filtering_not_submitted_terminations' do
    visit terminated_index_group_assignments_path(q: { termination_verified_by_id_null: 'true' })
    click_link 'Ende Bestätigt'
    click_link exact_text: 'Unbestätigt'
    visit current_url
    assert page.has_text? termination_index_table_text(@un_submitted)
    refute page.has_text? termination_index_table_text(@submitted)
  end

  test 'filtering_for_only_verified' do
    visit terminated_index_group_assignments_path(q: { termination_verified_by_id_null: 'true' })
    click_link 'Quittiert: Unquittiert'
    click_link exact_text: 'Quittiert'
    visit current_url
    refute page.has_text? termination_index_table_text(@un_submitted)
    refute page.has_text? termination_index_table_text(@submitted)
    assert page.has_text? termination_index_table_text(@verified)
  end

  test 'ended_assignment_can_be_verified' do
    visit group_offers_path
    click_link 'Beendete Begleitungen'
    assert page.has_text? termination_index_table_text(@un_submitted)
    assert page.has_text? termination_index_table_text(@submitted)
    refute page.has_text? termination_index_table_text(@verified)

    page.find_all('a', text: 'Beendigung Quittieren').first.click
    click_link 'Beendigung Quittieren'

    assert page.has_text? 'Beendete Gruppen Begleitungen'
    refute page.has_text? termination_index_table_text(@un_submitted)
    refute page.has_text? termination_index_table_text(@submitted)
    refute page.has_text? termination_index_table_text(@verified)
  end

  test 'clear_filter_link_is_working_correctly' do
    visit group_offers_path
    click_link 'Beendete Begleitungen'
    click_link 'Quittiert: Unquittiert'
    click_link exact_text: 'Quittiert'
    visit current_url
    click_link 'Ende Bestätigt'
    click_link exact_text: 'Bestätigt'
    visit current_url
    click_link 'Filter aufheben'
    visit current_url
    assert page.has_text? termination_index_table_text(@un_submitted)
    assert page.has_text? termination_index_table_text(@submitted)
    refute page.has_text? termination_index_table_text(@not_ended)
    refute page.has_text? termination_index_table_text(@verified)
  end

  test 'there_is_correct_links_to_the_termination_forms' do
    visit terminated_index_group_assignments_path(q: { termination_verified_by_id_null: 'true' })
    assert page.has_link? 'Beendigungsformular', href: terminate_group_assignment_path(@un_submitted.id)
    assert page.has_link? 'Beendigungsformular', href: terminate_group_assignment_path(@submitted.id)
  end

  test 'there_is_correct_links_to_creating_certificates' do
    visit terminated_index_group_assignments_path(q: { termination_verified_by_id_null: 'true' })
    refute page.has_link? 'Dossier Freiwillig engagiert erstellen',
      href: new_volunteer_certificate_path(@un_submitted.volunteer.id)
    assert page.has_link? 'Dossier Freiwillig engagiert erstellen',
      href: new_volunteer_certificate_path(@submitted.volunteer.id)
  end

  test 'group_assignment_quittieren_creates_a_group_assignment_log_record_from_group_assignment' do
    visit terminated_index_group_assignments_path(q: { termination_verified_by_id_null: 'true' })
    click_link 'Beendigung Quittieren', href: verify_termination_group_assignment_path(@submitted.id)
    assert page.has_text? 'Der Gruppeneinsatz wurde erfolgreich quittiert.'
    assert_equal @submitted, GroupAssignmentLog.find_by(group_assignment_id: @submitted.id).group_assignment
  end

  test 'there_is_correct_links_on_email_status_column' do
    create :email_template_termination
    visit terminated_index_group_assignments_path(q: { termination_verified_by_id_null: 'true' })

    # GroupAssignment has an end-date, but no reminder mailing was created
    click_link 'Beendigungs Email erstellen',
      href: new_termination_group_assignment_reminder_mailings_path(@un_submitted)
    click_button 'Erstellen und Vorschau anzeigen'

    # GroupAssignment has an end-date, reminder mailing was created, but not sent
    visit terminated_index_group_assignments_path(q: { termination_verified_by_id_null: 'true' })
    click_link 'Nicht versandt', href: reminder_mailing_path(@un_submitted.reminder_mailings
      .termination.last)
    click_link 'Email versenden'
    assert page.has_text? 'Beendigungs-Email wird versendet.'

    # GroupAssignment has an end-date, reminder mailing was created and was sent
    visit terminated_index_group_assignments_path(q: { termination_verified_by_id_null: 'true' })
    @un_submitted.reload
    assert page.has_link? 'Übermittelt am ',
      href: reminder_mailing_path(@un_submitted.reminder_mailings.termination.last)

    click_link 'Beendigung Quittieren', href: /group_assignments\/#{@un_submitted.id}\/verify_termination/
    assert page.has_text? 'Der Gruppeneinsatz wurde erfolgreich quittiert.'

    visit terminated_index_group_assignments_path(q: { termination_verified_by_id_not_null: 'true' })
    @un_submitted.reload
    assert page.has_text? "Quittiert von #{@un_submitted.termination_verified_by.full_name} am"\
      " #{I18n.l(@un_submitted.termination_verified_at.to_date)}"
  end
end
