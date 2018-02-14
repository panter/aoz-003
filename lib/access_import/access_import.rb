require 'securerandom'
require 'ostruct'

class AccessImport
  include AccessImportSetup
  include AccessImportTransformers

  def make_departments
    puts 'Importing Departments'
    department_transform.import_all
    display_stats(Department)
  end

  def make_clients
    puts 'Importing Clients'
    client_transform.import_all
    display_stats(Client)
  end

  def make_volunteers
    puts 'Importing Volunteers'
    volunteer_transform.import_all
    display_stats(Volunteer)
  end

  def make_assignments
    puts 'Importing Assignments'
    assignment_transform.import_all
    display_stats(Assignment)
  end

  def make_group_offers
    puts 'Importing GroupOffers'
    # puts '... from Kurse'
    # kurs_transform.import_all
    # display_stats(GroupOffer)
    # display_stats(GroupAssignment)
    puts '... from Animation f'
    group_offer_transform.import_all
    display_stats(GroupOffer)
    display_stats(GroupAssignment)
    puts '... from Kurzeinsatz'
    group_offer_transform.import_all(@freiwilligen_einsaetze.where_kurzeinsatz)
    display_stats(GroupOffer)
    display_stats(GroupAssignment)
    puts '... from Andere'
    group_offer_transform.import_all(@freiwilligen_einsaetze.where_andere)
    display_stats(GroupOffer)
    display_stats(GroupAssignment)
  end

  def make_journal
    puts 'Importing Journals'
    journal_transform.import_all
    display_stats(Journal)
  end

  def make_hours
    puts 'Importing Hours'
    hour_transform.import_all
    display_stats(Hour)
  end

  def make_billing_expenses
    puts 'Importing BillingExpenses'

    display_stats(BillingExpense, Volunteer)
  end

  def self.finalize
    proc { User.find_by(email: EMAIL).delete }
  end
end
