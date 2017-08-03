require 'access_import/acc_utils'

class ClientTransform
  include AccUtils

  def initialize(acimport)
    @begleitete = acimport.begleitete
    @haupt_personen = acimport.haupt_personen
    @sprache_hauptperson = acimport.sprache_hauptperson
    @laender = acimport.laender
    @personen_rollen = acimport.personen_rollen
    @familien_rollen = acimport.familien_rollen
    @plz = acimport.plz
  end

  def prepare_attributes(personen_rolle)
    haupt_person = @haupt_personen.find(personen_rolle[:fk_Hauptperson])
    begleitet, relatives = handle_begleitete(personen_rolle, haupt_person)
    familien_rolle = @familien_rollen.find(begleitet[:fk_FamilienRolle])
    plz = @plz.find(haupt_person[:fk_PLZ])
    sprachen = @sprache_hauptperson.where_person(haupt_person[:pk_Hauptperson])
    {
      salutation: salutation(haupt_person[:t_Anrede]),
      comments: comments(begleitet, personen_rolle, haupt_person),
      birth_year: birth_year(haupt_person[:d_Geburtsdatum], begleitet[:z_Jahrgang]),
      entry_year: haupt_person[:d_EintrittCH] && haupt_person[:d_EintrittCH],
      nationality: haupt_person[:fk_Land] && @laender.find(haupt_person[:fk_Land]),
      language_skills_attributes: language_skills_attributes(sprachen),
      contact_attributes: contact_attributes(haupt_person, plz),
      relatives_attributes: relatives_attrs(relatives),
      import_attributes: access_import(begleitet, haupt_person, personen_rolle,
        familien_rolle, sprachen)
    }
  end

  def comments(begleitet, personen_rolle, haupt_person)
    comments = ''
    comments += "#{begleitet[:m_Bemerkung]}\n\n" if begleitet[:m_Bemerkung]
    comments += "#{personen_rolle[:m_Bemerkungen]}\n\n" if personen_rolle[:m_Bemerkungen]
    comments += "#{haupt_person[:m_Bemerkungen]}\n\n" if haupt_person[:m_Bemerkungen]
    comments
  end

  def handle_begleitete(personen_rolle, haupt_person)
    begleitete = @begleitete.where_personen_rolle(personen_rolle[:pk_PersonenRolle])
    return [begleitete.first[1], []] if begleitete.size == 1
    begleitet = begleitete.select do |_key, beg|
      beg[:fk_FamilienRolle] == 2 # Hauptperson
    end
    if begleitet.size == 1
      return [begleitet.first[1], begleitete.except(begleitet.first[0])]
    end
    begleitet = begleitete.select do |_key, beg|
      beg[:t_Vorname] == haupt_person[:t_Vorname]
    end
    if begleitet.size == 1
      return [begleitet.first[1], begleitete.except(begleitet.first[0])]
    end
    begleitet = begleitete.select do |_key, beg|
      haupt_person[:t_Vorname].include? beg[:t_Vorname]
    end
    # either last match worked or nothing worked, just take first in order to
    # have a at least somewhat consistent thing
    [begleitet.first[1], begleitete.except(begleitet.first[0])]
  end

  def relatives_attrs(relatives)
    relatives.map do |_key, relative|
      [(Time.now.to_f * 1000).to_i, {
        first_name: relative[:t_Vorname],
        last_name: relative[:t_Name], relation: relative[:relation],
        birth_year: relative[:z_Jahrgang] && Date.parse("#{relative[:z_Jahrgang]}-01-01")
      }]
    end.to_h
  end

  def birth_year(geburtsdatum, jahrgang)
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
      access_id: fields[2][:pk_PersonenRolle],
      store: {
        id_personen_rolle: fields[2][:pk_PersonenRolle],
        begleitet: down_hkeys(fields[0].slice(:fk_FamilienRolle, :fk_PersonenRolle, :pk_Begleitete,
          :m_Bemerkung, :z_Jahrgang)),
        haupt_person: down_hkeys(fields[1].slice(:b_KlientAOZ, :fk_Land, :fk_PLZ, :t_Anrede,
          :t_NNummer, :pk_Hauptperson)),
        personen_rolle: down_hkeys(fields[2]),
        familien_rolle: down_hkeys(fields[3].except(:d_MutDatum, :t_Mutation))
      }
    }
  end

  def contact_attributes(haupt_person, plz)
    {
      first_name: haupt_person[:t_Vorname] || 'unbekannt',
      last_name: haupt_person[:t_Nachname] || 'unbekannt',
      city: plz[:t_Ort],
      street: haupt_person[:t_Adresszeile1] || 'unbekannt',
      extended: haupt_person[:t_Adresszeile2],
      postal_code: plz[:t_PLZ],
      primary_email: email(haupt_person[:h_Email]),
      primary_phone: haupt_person[:t_Telefon1] || '000 000 00 00',
      secondary_phone: haupt_person[:t_Telefon2] && haupt_person[:t_Telefon2]
    }
  end
end
