namespace :access do
  desc 'TODO'
  task import: :environment do
    acdb = Mdb.open('db/volunteers_prog.accdb')
    binding.pry
  end
end
