namespace :access do
  desc 'TODO'
  task import: :environment do
    @acimport = AccessImport.new('db/volunteers_data.accdb')
    @acimport.make_clients
  end
end
