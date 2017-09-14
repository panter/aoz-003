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
end
