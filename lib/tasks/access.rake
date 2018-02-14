namespace :access do
  desc 'TODO'
  task import: :environment do
    if ENV['file'].present?
      @acimport = AccessImport.new(ENV['file'])
      @acimport.make_departments
      @acimport.make_assignments
      @acimport.make_group_offers
      @acimport.make_clients
      @acimport.make_volunteers
      @acimport.make_hours
      @acimport.make_journal
      @acimport.overall_stats
    else
      warn 'No access file set. run "rails access:import file=path/to/access_file.accdb"'
    end
  end
end
