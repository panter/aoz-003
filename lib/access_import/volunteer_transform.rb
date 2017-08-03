require_all 'lib/access_import'

class VolunteerTransform
  include AccUtils

  def initialize(acimport)
    @haupt_personen = acimport.haupt_personen
    @sprache_hauptperson = acimport.sprache_hauptperson
    @laender = acimport.laender
    @personen_rollen = acimport.personen_rollen
    @plz = acimport.plz
    @kosten_traeger = acimport.kosten_traeger
    @journale = acimport.journale
    @fw_einsaetze = acimport.fw_einsaetze
    @fw_entschaedigung = acimport.fw_entschaedigung
    @fallstelle_teilnehmer = acimport.fallstelle_teilnehmer
    @konto_angaben = acimport.konto_angaben
    @stundenerfassung = acimport.stundenerfassung
  end

  def prepare_attributes(personen_rolle)
    haupt_person = @haupt_personen.find(personen_rolle[:fk_Hauptperson])
    plz = @plz.find(haupt_person[:fk_PLZ])
    sprachen = @sprache_hauptperson.where_person(haupt_person[:pk_Hauptperson])
    k_traeger = @kosten_traeger.find(personen_rolle[:fk_Kostenträger])
    journals = @journale.where_haupt_person(haupt_person[:pk_Hauptperson])
    einsaetze = @fw_einsaetze.where_personen_rolle(personen_rolle[:pk_PersonenRolle])
    entschaedigungen = @fw_entschaedigung.where_personen_rolle(personen_rolle[:pk_PersonenRolle])
    konto_angaben = @konto_angaben.where_haupt_person(haupt_person[:pk_Hauptperson])
    stunden_erfassungen = @stundenerfassung.where_personen_rolle(personen_rolle[:pk_PersonenRolle])
    binding.pry
    {
      salutation: salutation(haupt_person[:t_Anrede]),
      birth_year: birth_year(haupt_person[:d_Geburtsdatum]),
      nationality: haupt_person[:fk_Land] && @laender.find(haupt_person[:fk_Land]),
      language_skills_attributes: language_skills_attributes(sprachen),
      contact_attributes: contact_attributes(haupt_person, plz),
      access_import: access_import(haupt_person, personen_rolle, sprachen, k_traeger)
    }
  end

  def birth_year(geburtsdatum)
    return geburtsdatum if geburtsdatum
    Date.parse(jahrgang + '-06-01') if jahrgang
  end

  def language_skills_attributes(sprachen)
    sprachen.map do |sprache|
      [
        (Time.now.to_f * 1000).to_i,
        { language: sprache[:language][:lang], level: sprache[:kenntnisstufe_ve] }
      ]
    end.to_h
  end

  def access_import(*fields)
    {
      id_personen_rolle: fields[1][:pk_PersonenRolle],
      haupt_person: down_hkeys(fields[0].slice(:b_KlientAOZ, :fk_Land, :fk_PLZ, :t_Anrede,
        :t_NNummer, :pk_Hauptperson)),
      personen_rolle: down_hkeys(fields[1]),
      kosten_traeger: down_hkeys(fields[3])
    }
  end

  def contact_attributes(haupt_person, plz)
    mobile_number(haupt_person).merge(
      first_name: haupt_person[:t_Vorname] || 'unbekannt',
      last_name: haupt_person[:t_Nachname] || 'unbekannt',
      city: plz[:t_Ort],
      street: haupt_person[:t_Adresszeile1] || 'unbekannt',
      extended: haupt_person[:t_Adresszeile2],
      postal_code: plz[:t_PLZ],
      primary_email: email(haupt_person[:h_Email]),
      primary_phone: haupt_person[:t_Telefon1] || '000 000 00 00'
    )
  end

  def mobile_number(haupt_person)
    return {} unless haupt_person[:t_Telefon2]
    {
      contact_phones_attributes: [
        [(Time.now.to_f * 1000).to_i, { body: haupt_person[:t_Telefon2], label: 'mobile' }]
      ].to_h
    }
  end
end
