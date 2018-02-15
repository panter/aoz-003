class BillingExpenseTransform < Transformer
  def prepare_attributes(entschaedigung)
    {
      hours: get_hours(entschaedigung),
      volunteer: get_volunteer(entschaedigung),
      amount: entschaedigung[:z_Betrag],
      user: @ac_import.import_user,
      bank: entschaedigung[:t_Empfängerkonto],
      import_attributes: access_import(
        :tbl_FreiwilligenEntschädigung, entschaedigung[:pk_FreiwilligenEntschädigung],
        entschaedigung: entschaedigung
      )
    }
  end

  def get_or_create_by_import(entschaedigung_id, entschaedigung = nil)
    billing_expense = Import.get_imported(BillingExpense, entschaedigung_id)
    return billing_expense if billing_expense.present?
    entschaedigung ||= @freiwilligen_entschaedigung.find(entschaedigung_id)
    binding.pry
    billing_expense = BillingExpense.new(prepare_attributes(entschaedigung))
    billing_expense.skip_validation_for_import = true
    billing_expense.save!
  end

  def import_multiple(entschaedigungen)
    entschaedigungen.map do |key, entschaedigung|
      get_or_create_by_import(key, entschaedigung)
    end
  end

  def import_all(entschaedigungen = nil)
    import_multiple(entschaedigungen || @freiwilligen_entschaedigung.all)
  end

  def get_hours(entschaedigung)
    return @hours if @hours.presence
    # trigger import, but drop result, in order to have active record query result
    @ac_import.hour_transform.import_all(
      @stundenerfassung.where_personen_rolle(entschaedigung[:fk_PersonenRolle])
    )
    # get hours as active record query
    @hours = Hour.where(volunteer: get_volunteer(entschaedigung))
  end

  def get_volunteer(entschaedigung)
    @volunteer ||= @ac_import.volunteer_transform
                             .get_or_create_by_import(entschaedigung[:fk_PersonenRolle])
  end
end
