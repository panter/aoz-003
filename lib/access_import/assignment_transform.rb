require 'acc_utils'

class AssignmentTransform
  include AccUtils

  def initialize(*accessors)
    accessors.each do |accessor|
      instance_variable_set("@#{accessor.class.name.underscore}", accessor)
    end
  end

  def prepare_attributes(fw_einsatz)
    begleitet = @begleitete.find(fw_einsatz[:fk_Begleitete])
    client_import = Import.find_by(access_id: begleitet[:fk_PersonenRolle])
    volunteer_import = Import.find_by(access_id: fw_einsatz[:fk_PersonenRolle])
    {
      client_id: client_import.importable.id,
      volunteer_id: volunteer_import.importable.id,
      state: fw_einsatz[:d_EinsatzBis] < Time.zone.now ? 'finished' : 'active',
      import_attributes: access_import(
        fw_einsatz, :pk_FreiwilligenEinsatz, begleitet, volunteer_access_id: volunteer_import.access_id,
        client_access_id: client_import.access_id
      )
    }
  end
end
