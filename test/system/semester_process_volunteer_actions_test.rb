require 'application_system_test_case'

class SemesterProcessVolunteerActionsTest < ApplicationSystemTestCase
  setup do
    @superadmin = create :user
    @volunteer = create :volunteer_with_user
    @assignment = create :assignment, volunteer: @volunteer
    @group_assignment = create :group_assignment, volunteer: @volunteer

    @semester_process = create :semester_process
    @spv1 = create(:semester_process_volunteer, :with_mission, volunteer: @volunteer,
      semester_process: @semester_process)

    login_as @superadmin
  end

  test 'take responsibility for semester process volunteer works' do
    visit semester_process_volunteers_path
    within 'tbody' do
      page.find("[data-url$=\"#{take_responsibility_semester_process_volunteer_path(@spv1)}\"]").click
    end
    wait_for_ajax
    @spv1.reload
    assert page.has_text? "Übernommen durch #{@superadmin.email}"\
    " am #{I18n.l(@spv1.responsibility_taken_at.to_date)}"
  end

  test 'take_feedback_responsibility_filter_works' do
    # TODO: add filter test
    # filter: Alle
    # filter: Offen
    # filter: Übernommen
    # filter: Übernommen von
  end
end
