require 'application_system_test_case'

class VolunteerShowAssignmentsTest < ApplicationSystemTestCase
  def setup
    @superadmin = create :superadmin
    @volunteer = create :volunteer
    @assignment = create :assignment, client: create(:client),
                                      volunteer: @volunteer,
                                      period_start: 3.weeks.ago,
                                      period_end: nil,
                                      creator: @superadmin
    @log_creator = create :superadmin
    @log_client = create :client
    @assignment_log = create :assignment, client: @log_client,
                                          volunteer: @volunteer,
                                          period_start: 2.weeks.ago,
                                          period_end: 2.days.ago,
                                          creator: @log_creator,
                                          termination_submitted_at: 2.days.ago,
                                          termination_submitted_by: @volunteer.user,
                                          period_end_set_by: @log_creator
    @assignment_log.verify_termination(@superadmin)
    @assignment_log.update(termination_verified_at: 2.days.ago)
  end

  test 'volunteer_show_view_displays_assignment_and_assignment_log_for_superadmin' do
    login_as @superadmin
    visit volunteer_path(@volunteer)
    within '.assignments-table' do
      assert_text start_end_localized(@assignment)
      refute_text start_end_localized(@assignment_log), wait: 0

      client_creator_names(@assignment).each do |name|
        assert_text name
      end
    end

    within '.assignment-logs-table' do
      assert_text start_end_localized(@assignment_log)
      refute_text start_end_localized(@assignment), wait: 0
      client_creator_names(@assignment_log).each do |name|
        assert_text name
      end
    end
  end

  test 'volunteer_show_view_displays_assignment_and_assignment_log_for_volunteer' do
    login_as @volunteer.user
    visit volunteer_path(@volunteer)
    within '.assignments-table' do
      assert_text start_end_localized(@assignment)
      refute_text start_end_localized(@assignment_log), wait: 0
      client_creator_names(@assignment).each do |name|
        assert_text name
      end
    end

    within '.assignment-logs-table' do
      assert_text start_end_localized(@assignment_log)
      refute_text start_end_localized(@assignment), wait: 0
      client_creator_names(@assignment_log).each do |name|
        assert_text name
      end
    end
  end

  def client_creator_names(assignment)
    [assignment.client.contact.full_name, assignment.creator.full_name]
  end

  def start_end_localized(assignment)
    assignment.attributes
              .values_at('period_start', 'period_end')
              .compact
              .map { |d| I18n.l(d) }
              .join(' ')
  end
end
