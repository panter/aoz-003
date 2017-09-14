namespace :access do
  desc 'TODO'
  task import: :environment do
    if ENV['file'].present?
      @acimport = AccessImport.new(ENV['file'])
      @acimport.make_departments
      @acimport.make_clients
      @acimport.make_volunteers
      @acimport.make_assignments
      @acimport.make_journal
    else
      puts 'No access file set. run "rails access:import file=path/to/access_file.accdb"'
    end
  end
end
