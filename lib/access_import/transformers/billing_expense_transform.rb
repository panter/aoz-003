class BillingExpenseTransform < Transformer
  def prepare_attributes(entschaedigung, volunteer)
    {
      volunteer: volunteer,
      amount: entschaedigung[:z_Betrag],
      user: @ac_import.import_user,
      bank: entschaedigung[:t_Empfängerkonto],
      iban: volunteer.iban,
      import_attributes: access_import(
        :tbl_FreiwilligenEntschädigung, entschaedigung[:pk_FreiwilligenEntschädigung],
        entschaedigung: entschaedigung
      )
    }
  end

  def get_or_create_by_import(entschaedigung_id, entschaedigung = nil)
    return @entity if get_import_entity(:billing_expense, entschaedigung_id).present?
    entschaedigung ||= @freiwilligen_entschaedigung.find(entschaedigung_id)
    volunteer = get_volunteer(entschaedigung[:fk_PersonenRolle])
    return if volunteer.blank?
    billing_expense = BillingExpense.new(prepare_attributes(entschaedigung, volunteer))
    billing_expense.skip_validation_for_import = true
    billing_expense.save!
    if entschaedigung[:z_Stunden].positive?
      Hour.create(volunteer: volunteer, hourable: volunteer.assignments&.last || volunteer.group_offers&.last,
        billing_expense: billing_expense, hours: entschaedigung[:z_Stunden], meeting_date: entschaedigung[:d_Datum])
    end
    billing_expense.update(updated_at: entschaedigung[:d_Datum], created_at: entschaedigung[:d_Datum])
    billing_expense
  end

  def import_multiple(entschaedigungen)
    entschaedigungen.map do |key, entschaedigung|
      get_or_create_by_import(key, entschaedigung)
    end
  end

  def import_all(entschaedigungen = nil)
    import_multiple(entschaedigungen || @freiwilligen_entschaedigung.all)
  end

  def get_volunteer(personen_rollen_id)
    @ac_import.volunteer_transform.get_or_create_by_import(personen_rollen_id)
  end
end
