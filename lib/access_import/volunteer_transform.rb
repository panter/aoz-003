require 'acc_utils'

class VolunteerTransform
  include AccUtils

  def initialize(*accessors)
    accessors.each do |accessor|
      instance_variable_set("@#{accessor.class.name.underscore}", accessor)
    end
  end

  # could be needed relations
  #
  # k_traeger = @kosten_traeger.find(personen_rolle[:fk_Kostenträger])
  # journals = @journale.where_haupt_person(haupt_person[:pk_Hauptperson])
  # einsaetze = @fw_einsaetze.where_personen_rolle(personen_rolle[:pk_PersonenRolle])
  # entschaedigungen = @fw_entschaedigung.where_personen_rolle(personen_rolle[:pk_PersonenRolle])
  # konto_angaben = @konto_angaben.where_haupt_person(haupt_person[:pk_Hauptperson])
  # stunden_erfassungen = @stundenerfassung.where_personen_rolle(personen_rolle[:pk_PersonenRolle])
  #
  def prepare_attributes(personen_rolle)
    haupt_person = @haupt_person.find(personen_rolle[:fk_Hauptperson])
    {
      salutation: haupt_person[:salutation],
      birth_year: haupt_person[:d_Geburtsdatum],
      nationality: haupt_person[:nationality],
      language_skills_attributes: language_skills_attributes(haupt_person[:sprachen]),
      contact_attributes: contact_attributes(haupt_person),
      import_attributes: access_import(
        :tbl_Personenrollen, personen_rolle[:pk_PersonenRolle], personen_rolle: personen_rolle,
        haupt_person: haupt_person
      )
    }
  end
end
