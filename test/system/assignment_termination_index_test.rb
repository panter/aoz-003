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

  test 'visiting termination index displays correct assignments' do
    visit assignments_path
    click_link 'Beendete Begleitungen'
    assert page.has_text? "#{@un_submitted.volunteer.contact.full_name} "\
      "#{@un_submitted.client.contact.full_name} #{I18n.l(@un_submitted.period_start)} "\
      "#{I18n.l(@un_submitted.period_end)}"
    assert page.has_text? "#{@submitted.volunteer.contact.full_name} "\
      "#{@submitted.client.contact.full_name} #{I18n.l(@submitted.period_start)} "\
      "#{I18n.l(@submitted.period_end)}"
    refute page.has_text? "#{@not_ended.volunteer.contact.full_name} "\
      "#{@not_ended.client.contact.full_name} #{I18n.l(@not_ended.period_start)} "
    refute page.has_text? "#{@verified.volunteer.contact.full_name} "\
      "#{@verified.client.contact.full_name} #{I18n.l(@verified.period_start)} "\
      "#{I18n.l(@verified.period_end)}"
  end

  test 'filtering_submitted_terminations' do
    visit terminated_index_assignments_path(q: { termination_verified_by_id_null: 'true' })
    click_link 'Ende Bestätigt'
    click_link exact_text: 'Bestätigt'
    visit current_url
    refute page.has_text? "#{@un_submitted.volunteer.contact.full_name} "\
      "#{@un_submitted.client.contact.full_name} #{I18n.l(@un_submitted.period_start)} "\
      "#{I18n.l(@un_submitted.period_end)}"
    assert page.has_text? "#{@submitted.volunteer.contact.full_name} "\
      "#{@submitted.client.contact.full_name} #{I18n.l(@submitted.period_start)} "\
      "#{I18n.l(@submitted.period_end)}"
  end

  test 'filtering_not_submitted_terminations' do
    visit terminated_index_assignments_path(q: { termination_verified_by_id_null: 'true' })
    click_link 'Ende Bestätigt'
    click_link exact_text: 'Unbestätigt'
    visit current_url
    assert page.has_text? "#{@un_submitted.volunteer.contact.full_name} "\
      "#{@un_submitted.client.contact.full_name} #{I18n.l(@un_submitted.period_start)} "\
      "#{I18n.l(@un_submitted.period_end)}"
    refute page.has_text? "#{@submitted.volunteer.contact.full_name} "\
      "#{@submitted.client.contact.full_name} #{I18n.l(@submitted.period_start)} "\
      "#{I18n.l(@submitted.period_end)}"
  end

  test 'filtering_for_only_verified' do
    visit terminated_index_assignments_path(q: { termination_verified_by_id_null: 'true' })
    click_link 'Quitiert: Unquittiert'
    click_link exact_text: 'Quittiert'
    visit current_url
    refute page.has_text? "#{@un_submitted.volunteer.contact.full_name} "\
      "#{@un_submitted.client.contact.full_name} #{I18n.l(@un_submitted.period_start)} "\
      "#{I18n.l(@un_submitted.period_end)}"
    refute page.has_text? "#{@submitted.volunteer.contact.full_name} "\
      "#{@submitted.client.contact.full_name} #{I18n.l(@submitted.period_start)} "\
      "#{I18n.l(@submitted.period_end)}"
    assert page.has_text? "#{@verified.volunteer.contact.full_name} "\
      "#{@verified.client.contact.full_name} #{I18n.l(@verified.period_start)} "\
      "#{I18n.l(@verified.period_end)}"
  end
end
