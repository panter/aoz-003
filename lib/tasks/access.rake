namespace :access do
  desc 'TODO'
  task import: :environment do
    acdb = Mdb.open('db/volunteers_data.accdb')
    tables = [
      'tbl_Ausbildungen', 'tbl_AusbildungsTypen', 'tbl_AuswVorlagen', 'tbl_Begleitete',
      'tbl_EinsatzOrteProEinsatzFunktion', 'tbl_FallStellen', 'tbl_FallStelleProTeilnehmer',
      'tbl_FamilienRollen', 'tbl_FreiwilligenEinsätze', 'tbl_FreiwilligenEntschädigung',
      'tbl_FreiwilligenVeranstaltungen', 'tbl_Hauptpersonen', 'tbl_Journal',
      'tbl_JournalKategorien', 'tbl_Kantone', 'tbl_KontaktPersonen', 'tbl_Kontoangaben',
      'tbl_Kostenträger', 'tbl_Kurse', 'tbl_Kurspräsenzen', 'tbl_Kursteilnehmer', 'tbl_Länder',
      'tbl_Lehrmittel', 'tbl_ParameterZ', 'tbl_Personenrollen', 'tbl_PlzOrt', 'tbl_Rollen',
      'tbl_Semester', 'tbl_Spesenansätze', 'tbl_Sprachen', 'tbl_Sprachkenntnisse',
      'tbl_Stundenerfassung', 'tbl_Veranstaltungen', 'tbl_Veranstaltungsteilnehmer',
      'tbl_VerfahrensHistory', 'tbl_Verfahrensstati', 'tbl_VersionData', 'tbl_EinsatzOrte',
      'tbl_FreiwilligenFunktionen', 'tbl_Kursarten', 'tbl_ParameterT', 'tbl_SpracheProHauptperson'
    ]
    binding.pry
  end

  def notes
    tables = [
      'tbl_Ausbildungen', 'tbl_AusbildungsTypen', 'tbl_AuswVorlagen', 'tbl_Begleitete',
      'tbl_EinsatzOrteProEinsatzFunktion', 'tbl_FallStellen', 'tbl_FallStelleProTeilnehmer',
      'tbl_FamilienRollen', 'tbl_FreiwilligenEinsätze', 'tbl_FreiwilligenEntschädigung',
      'tbl_FreiwilligenVeranstaltungen', 'tbl_Hauptpersonen', 'tbl_Journal',
      'tbl_JournalKategorien', 'tbl_Kantone', 'tbl_KontaktPersonen', 'tbl_Kontoangaben',
      'tbl_Kostenträger', 'tbl_Kurse', 'tbl_Kurspräsenzen', 'tbl_Kursteilnehmer', 'tbl_Länder',
      'tbl_Lehrmittel', 'tbl_ParameterZ', 'tbl_Personenrollen', 'tbl_PlzOrt', 'tbl_Rollen',
      'tbl_Semester', 'tbl_Spesenansätze', 'tbl_Sprachen', 'tbl_Sprachkenntnisse',
      'tbl_Stundenerfassung', 'tbl_Veranstaltungen', 'tbl_Veranstaltungsteilnehmer',
      'tbl_VerfahrensHistory', 'tbl_Verfahrensstati', 'tbl_VersionData', 'tbl_EinsatzOrte',
      'tbl_FreiwilligenFunktionen', 'tbl_Kursarten', 'tbl_ParameterT', 'tbl_SpracheProHauptperson'
    ]

    keys_tbl_Personenrollen = [
      :pk_PersonenRolle, :fk_Hauptperson, :fk_Kostenträger, :z_Rolle, :d_Rollenbeginn,
      :d_Rollenende, :z_Familienverband, :z_AnzErw, :z_AnzKind, :m_Bemerkungen, :b_Interesse,
      :b_EinführungsKurs, :b_SpesenVerzicht, :t_Mutation, :d_MutDatum
    ]

    keys_tbl_Begleitete = [
      :pk_Begleitete, :fk_PersonenRolle, :fk_FamilienRolle, :t_Name, :t_Vorname, :t_Geschlecht,
      :z_Jahrgang, :m_Bemerkung, :t_Mutation, :d_MutDatum
    ]
  end
end
