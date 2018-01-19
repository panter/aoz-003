require 'application_system_test_case'

class AssignmentTerminationIndexTest < ApplicationSystemTestCase
  setup do
    @superadmin = create :user
    @volunteer = create :volunteer_with_user
    @not_ended = create :assignment, period_start: 3.weeks.ago, period_end: nil
    @un_submitted = create :assignment, period_start: 3.weeks.ago, period_end: 2.days.ago
    @submitted = create :assignment, period_start: 3.weeks.ago, period_end: 2.days.ago,
      termination_submitted_at: 2.days.ago, termination_submitted_by: @volunteer.user
    @verified = create :assignment, period_start: 3.weeks.ago, period_end: 2.days.ago,
      termination_submitted_at: 2.days.ago, termination_submitted_by: @volunteer.user,
      termination_verified_at: 2.days.ago, termination_verified_by: @superadmin
    login_as @superadmin
  end

  def termination_index_table_text(assignment)
    row_text = "#{assignment.volunteer.contact.full_name} "\
        "#{assignment.client.contact.full_name} #{I18n.l(assignment.period_start)} "
    row_text += I18n.l(assignment.period_end) if assignment.period_end.present?
    row_text
  end

  test 'visiting_termination_index_displays_correct_assignments' do
    visit assignments_path
    click_link 'Beendete Begleitungen'
    assert page.has_text? termination_index_table_text(@un_submitted)
    assert page.has_text? termination_index_table_text(@submitted)
    refute page.has_text? termination_index_table_text(@not_ended)
    refute page.has_text? termination_index_table_text(@verified)
  end

  test 'filtering_submitted_terminations' do
    visit terminated_index_assignments_path(q: { termination_verified_by_id_null: 'true' })
    click_link 'Ende Bestätigt'
    click_link exact_text: 'Bestätigt'
    visit current_url
    refute page.has_text? termination_index_table_text(@un_submitted)
    assert page.has_text? termination_index_table_text(@submitted)
  end

  test 'filtering_not_submitted_terminations' do
    visit terminated_index_assignments_path(q: { termination_verified_by_id_null: 'true' })
    click_link 'Ende Bestätigt'
    click_link exact_text: 'Unbestätigt'
    visit current_url
    assert page.has_text? termination_index_table_text(@un_submitted)
    refute page.has_text? termination_index_table_text(@submitted)
  end

  test 'filtering_for_only_verified' do
    visit terminated_index_assignments_path(q: { termination_verified_by_id_null: 'true' })
    click_link 'Quittiert: Unquittiert'
    click_link exact_text: 'Quittiert'
    visit current_url
    refute page.has_text? termination_index_table_text(@un_submitted)
    refute page.has_text? termination_index_table_text(@submitted)
    assert page.has_text? termination_index_table_text(@verified)
  end

  test 'ended_assignment_can_be_verified' do
    visit assignments_path
    click_link 'Beendete Begleitungen'
    assert page.has_text? termination_index_table_text(@un_submitted)
    assert page.has_text? termination_index_table_text(@submitted)
    refute page.has_text? termination_index_table_text(@verified)

    page.find_all('a', text: 'Beendigung Quittieren').first.click
    click_link 'Beendigung Quittieren'

    assert page.has_text? 'Beendete Begleitungen'
    refute page.has_text? termination_index_table_text(@un_submitted)
    refute page.has_text? termination_index_table_text(@submitted)
    refute page.has_text? termination_index_table_text(@verified)
  end

  test 'clear_filter_link_is_working_correctly' do
    visit assignments_path
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
    visit terminated_index_assignments_path(q: { termination_verified_by_id_null: 'true' })
    assert page.has_link? 'Beendigungsformular', href: /assignments\/#{@un_submitted.id}\/terminate/
    assert page.has_link? 'Beendigungsformular', href: /assignments\/#{@submitted.id}\/terminate/
  end

  test 'there_is_correct_links_to_creating_certificates' do
    visit terminated_index_assignments_path(q: { termination_verified_by_id_null: 'true' })
    assert page.has_link? 'Dossier Freiwillig engagiert erstellen',
      href: /\/volunteers\/#{@un_submitted.volunteer.id}\/certificates\/new/
    assert page.has_link? 'Dossier Freiwillig engagiert erstellen',
      href: /\/volunteers\/#{@submitted.volunteer.id}\/certificates\/new/
  end

  test 'assignment_quittieren_creates_a_assignment_log_record_from_assignment' do
    visit terminated_index_assignments_path(q: { termination_verified_by_id_null: 'true' })
    click_link 'Beendigung Quittieren', href: verify_termination_assignment_path(@submitted.id)
    assert page.has_text? 'Der Einsatz wurde erfolgreich quittiert.'
    assert_equal @submitted, AssignmentLog.find_by(assignment_id: @submitted.id).assignment
  end
end
