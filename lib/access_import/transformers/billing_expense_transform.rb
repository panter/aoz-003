class BillingExpenseTransform < Transformer
  def prepare_attributes(entschaedigung, volunteer)
    {
      volunteer: volunteer,
      amount: entschaedigung[:z_Betrag],
      user: @ac_import.import_user,
      bank: entschaedigung[:t_Empfängerkonto],
      iban: volunteer.iban
    }.merge(import_attributes(:tbl_FreiwilligenEntschädigung,
      entschaedigung[:pk_FreiwilligenEntschädigung], entschaedigung: entschaedigung))
  end

  def get_or_create_by_import(entschaedigung_id, entschaedigung = nil)
    billing_expense = get_import_entity(:billing_expense, entschaedigung_id)
    return billing_expense if billing_expense.present?
    entschaedigung ||= @freiwilligen_entschaedigung.find(entschaedigung_id)
    volunteer = get_volunteer(entschaedigung[:fk_PersonenRolle])
    return if volunteer.blank?
    billing_expense = BillingExpense.new(prepare_attributes(entschaedigung, volunteer))
    billing_expense.import_mode = true
    billing_expense.save!
    if entschaedigung[:z_Stunden].positive?
      Hour.create(volunteer: volunteer, meeting_date: entschaedigung[:d_Datum],
        hourable: get_dummy_hour_hourable(volunteer),
        billing_expense: billing_expense, hours: entschaedigung[:z_Stunden])
    end
    update_timestamps(billing_expense, entschaedigung[:d_Datum])
  end

  def default_all
    @freiwilligen_entschaedigung.all
  end

  def get_volunteer(personen_rollen_id)
    @ac_import.volunteer_transform.get_or_create_by_import(personen_rollen_id)
  end

  def get_dummy_hour_hourable(volunteer)
    Assignment.with_deleted.find_by(volunteer: volunteer) ||
      GroupAssignment.with_deleted.find_by(volunteer: volunteer)&.group_offer
  end
end
