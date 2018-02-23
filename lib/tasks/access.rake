namespace :access do
  desc 'TODO'
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
end
