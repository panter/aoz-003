require 'securerandom'
require 'ostruct'

class AccessImport
  include AccessImportSetup
  include AccessImportTransformers

  def make_departments
    start_message(:department)
    department_transform.import_all
    display_stats(Department)
  end

  def make_clients
    start_message(:client)
    client_transform.import_all
    display_stats(Client)
  end

  def make_volunteers
    start_message(:volunteer)
    volunteer_transform.import_all

    display_stats(Volunteer)
  end

  def make_assignments
    start_message(:assignment)
    assignment_transform.import_all
    display_stats(Assignment, Volunteer, Client)
  end

  def make_group_offers
    start_message(:group_offer)

    # TODO: Need to find out if this import is really needed, and then fix it,
    #       because it possibly doesn't work propperly
    #
    # shell_message '... from Kurse'
    # kurs_transform.import_all
    # display_stats(GroupOffer, GroupAssignment)

    shell_message '... from Animation f'
    group_offer_transform.import_all
    display_stats(GroupOffer, GroupAssignment)
    shell_message '... from Kurzeinsatz'
    group_offer_transform.import_all(@freiwilligen_einsaetze.where_kurzeinsatz)
    display_stats(GroupOffer, GroupAssignment)
    shell_message '... from Andere'
    group_offer_transform.import_all(@freiwilligen_einsaetze.where_andere)
    display_stats(GroupOffer, GroupAssignment)
  end

  def make_journal
    start_message(:journal)
    Import.client.or(Import.volunteer).each do |import|
      journal_transform.import_all(
        @journale.where_haupt_person(import.store['haupt_person']['pk_Hauptperson'])
      )
    end
    display_stats(Journal)
  end

  def make_hours
    start_message(:hour)
    Import.volunteer.each do |import|
      hour_transform.import_all(
        @stundenerfassung.where_personen_rolle(import.access_id)
      )
    end
    display_stats(Hour)
  end

  def make_billing_expenses
    start_message(:billing_expense)
    Import.volunteer.each do |import|
      billing_expense_transform.import_all(
        @freiwilligen_entschaedigung.where_personen_rolle(import.access_id)
      )
    end
    display_stats(BillingExpense, Hour)
  end

  # Clean up after imports finished
  def self.finalize
    proc { User.find_by(email: EMAIL).delete } # Remove the import user with softdelete
  end
end
