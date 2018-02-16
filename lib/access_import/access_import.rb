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
    journal_transform.import_all
    display_stats(Journal)
  end

  def make_hours
    start_message(:hour)
    hour_transform.import_all
    display_stats(Hour)
  end

  def make_billing_expenses
    start_message(:billing_expense)
    billing_expense_transform.import_all
    display_stats(BillingExpense, Hour)
  end

  def terminate_clients
    Client.field_not_nil(:resigned_at).each do |client|
      client.resigned!
      client.update(updated_at: client.import.store['personen_rolle']['d_MutDatum'],
        resigned_at: client.import.store['personen_rolle']['d_Rollenende'])
    end

    Volunteer.field_not_nil(:resigned_at).each do |volunteer|
      volunteer.resigned!
      volunteer.update(updated_at: volunteer.import.store['personen_rolle']['d_MutDatum'],
        resigned_at: volunteer.import.store['personen_rolle']['d_Rollenende'])
    end
  end

  def self.finalize
    proc { User.find_by(email: EMAIL).delete }
  end
end
