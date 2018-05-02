namespace :access do
  desc 'Imports all from Access db given'
  task import: :environment do
    if ENV['file'].present?
      @acimport = AccessImport.new(ENV['file'])
      @acimport.make_departments
      @acimport.make_volunteers
      @acimport.make_clients
      @acimport.make_assignments
      @acimport.make_group_offers
      @acimport.make_billing_expenses
      @acimport.make_journal
      @acimport.make_hours
      @acimport.run_acceptance_termination_on_clients_and_volunteers
      @acimport.overall_stats
    else
      warn 'No access file set. run "rails access:import file=path/to/access_file.accdb"'
    end
  end

  desc 'Set all Volunteers that where imported and created before May 2018 to intro_course = true'
  task cleanup_afterwards: :environment do
    # Make sure terminated assignments have log entry
    Assignment
      .terminated
      .left_joins(:assignment_log)
      .where('assignment_logs.id' => nil)
      .map(&:create_log_of_self)
    # Make sure terminated group_assignments have log entry
    GroupAssignment
      .terminated
      .left_joins(:group_assignment_logs)
      .where('group_assignment_logs.id' => nil)
      .map(&:create_log_of_self)

    Volunteer
      .created_before(Time.zone.parse('2018-04-30T23:59:59'))
      .update_all(intro_course: true, trial_period: true)
  end
end
