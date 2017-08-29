require 'acc_utils'

class DepartmentTransform
  include AccUtils

  def initialize(*accessors)
    accessors.each do |accessor|
      instance_variable_set("@#{accessor.class.name.underscore}", accessor)
    end
  end

  def prepare_attributes(einsatz_ort)
    {
      contact_attributes: {
        last_name: einsatz_ort[:t_EinsatzOrt],
        street: einsatz_ort[:t_Adresses],
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
