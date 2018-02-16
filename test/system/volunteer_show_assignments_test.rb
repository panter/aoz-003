require 'application_system_test_case'

class VolunteerShowAssignmentsTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :user
    @volunteer = create :volunteer_with_user
    @assignment = create :assignment, volunteer: @volunteer, period_start: 2.weeks.ago,
      period_end: nil, creator: @superadmin
    @assignment_log = create :assignment, volunteer: @volunteer, period_start: 2.weeks.ago,
      period_end: 2.days.ago, creator: @superadmin, termination_submitted_at: 2.days.ago,
      termination_submitted_by: @volunteer.user, period_end_set_by: @superadmin,
      termination_verified_at: 2.days.ago, termination_verified_by: @superadmin
    @assignment_log.destroy
  end

  test 'volunteer_show_view_displays_assignment_and_assignment_log_for_superadmin' do
    login_as @superadmin
    visit volunteer_path(@volunteer)
    within '.assignments-table' do
      assert page.has_text? "#{@assignment.client.contact.full_name} "\
        "#{I18n.l(@assignment.period_start)} #{@assignment.creator.full_name}"
      refute page.has_text? "#{@assignment_log.client.contact.full_name} "\
        "#{I18n.l(@assignment_log.period_start)} #{I18n.l(@assignment_log.period_end)} "\
        "#{@assignment_log.creator.full_name}"
    end
    within '.assignment-logs-table' do
      refute page.has_text? "#{@assignment.client.contact.full_name} "\
        "#{I18n.l(@assignment.period_start)} #{@assignment.creator.full_name}"
      assert page.has_text? "#{@assignment_log.client.contact.full_name} "\
        "#{I18n.l(@assignment_log.period_start)} #{I18n.l(@assignment_log.period_end)} "\
        "#{@assignment_log.creator.full_name}"
    end
  end

  test 'volunteer_show_view_displays_assignment_and_assignment_log_for_volunteer' do
    login_as @volunteer.user
    visit volunteer_path(@volunteer)
    within '.assignments-table' do
      assert page.has_text? "#{@assignment.client.contact.full_name} "\
        "#{I18n.l(@assignment.period_start)} #{@assignment.creator.full_name}"
      refute page.has_text? "#{@assignment_log.client.contact.full_name} "\
        "#{I18n.l(@assignment_log.period_start)} #{I18n.l(@assignment_log.period_end)} "\
        "#{@assignment_log.creator.full_name}"
    end
    within '.assignment-logs-table' do
      refute page.has_text? "#{@assignment.client.contact.full_name} "\
        "#{I18n.l(@assignment.period_start)} #{@assignment.creator.full_name}"
      assert page.has_text? "#{@assignment_log.client.contact.full_name} "\
        "#{I18n.l(@assignment_log.period_start)} #{I18n.l(@assignment_log.period_end)} "\
        "#{@assignment_log.creator.full_name}"
    end
  end
end
