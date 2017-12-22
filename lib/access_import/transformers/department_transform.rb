class DepartmentTransform < Transformer
  def prepare_attributes(einsatz_ort)
    {
      contact_attributes: {
        last_name: einsatz_ort[:t_EinsatzOrt],
        street: einsatz_ort[:t_Adresse1],
        extended: einsatz_ort[:t_Adresse2],
        postal_code: einsatz_ort[:postal_code],
        city: einsatz_ort[:city]
      },
      import_attributes: access_import(
        :tbl_EinsatzOrte, einsatz_ort[:pk_EinsatzOrt], einsatz_ort: einsatz_ort
      )
    }
  end

  def get_or_create_by_import(einsatz_ort_id, einsatz_ort = nil)
    department = Import.get_imported(Department, einsatz_ort_id)
    return department if department.present?
    parameters = prepare_attributes(einsatz_ort)
    department = Department.new(parameters)
    department.updated_at = einsatz_ort[:d_MutDatum]
    department.save!
    department
  end

  def import_multiple(einsatz_orte)
    einsatz_orte.map do |key, einsatz_ort|
      get_or_create_by_import(key, einsatz_ort)
    end
  end

  def import_all(einsatz_orte = nil)
    import_multiple(einsatz_orte || @einsatz_orte.all)
  end
end
