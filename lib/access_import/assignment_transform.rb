require 'acc_utils'

class AssignmentTransform
  include AccUtils

  def initialize(*accessors)
    accessors.each do |accessor|
      instance_variable_set("@#{accessor.class.name.underscore}", accessor)
    end
  end

  def prepare_attributes(fw_einsatz, client, volunteer, begleitet)
    {
      state: map_assignment_state(fw_einsatz[:d_EinsatzBis]),
      client_id: client.id,
      volunteer_id: volunteer.id,
      import_attributes: access_import(
        :tbl_FreiwilligenEinsätze, fw_einsatz[:pk_FreiwilligenEinsatz], fw_einsatz: fw_einsatz,
        begleitet: begleitet
      )
    }
  end

  def map_assignment_state(to_date)
    return 'archived' if to_date < now.years_ago(3)
    'active' if !to_date || to_date > now
  end
end
