namespace :access do
  desc 'TODO'
  task import: :environment do
    @acimport = AccessImport.new('db/volunteers_data.accdb')
    # @acimport.make_clients
    # @acimport.make_volunteers
    @acimport.make_assignments
  end
end
