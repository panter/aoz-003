namespace :access do
  desc 'TODO'
  task import: :environment do
    @acdb = Mdb.open('db/volunteers_data.accdb')
    familien_rollen = make_mappable('tbl_FamilienRollen', :pk_FamilienRolle)
    @acdb['tbl_Begleitete'].each do |begl|
      familien_rolle = familien_rollen[begl[:fk_FamilienRolle]]

      personen_rolle = @acdb['tbl_Personenrollen'].select do |pr|
        pr[:pk_PersonenRolle] == begl[:fk_PersonenRolle]
      end.first

      haupt_person = @acdb['tbl_Hauptpersonen'].select do |hp|
        hp[:pk_Hauptperson] == personen_rolle[:fk_Hauptperson]
      end.first
      binding.pry
    end
  end

  def make_mappable(table_name, primary_key)
    @acdb[table_name].map do |row|
      [row[primary_key], row.except(primary_key)]
    end.to_h
  end

  def down_acc_keys(row)
    row.keys.map do |key|
      [key.to_s.underscore.to_sym, val]
    end.to_h
  end

  def notes
  #   tables = [
  #     'tbl_Ausbildungen', 'tbl_AusbildungsTypen', 'tbl_AuswVorlagen', 'tbl_Begleitete',
  #     'tbl_EinsatzOrteProEinsatzFunktion', 'tbl_FallStellen', 'tbl_FallStelleProTeilnehmer',
  #     'tbl_FamilienRollen', 'tbl_FreiwilligenEinsätze', 'tbl_FreiwilligenEntschädigung',
  #     'tbl_FreiwilligenVeranstaltungen', 'tbl_Hauptpersonen', 'tbl_Journal',
  #     'tbl_JournalKategorien', 'tbl_Kantone', 'tbl_KontaktPersonen', 'tbl_Kontoangaben',
  #     'tbl_Kostenträger', 'tbl_Kurse', 'tbl_Kurspräsenzen', 'tbl_Kursteilnehmer', 'tbl_Länder',
  #     'tbl_Lehrmittel', 'tbl_ParameterZ', 'tbl_Personenrollen', 'tbl_PlzOrt', 'tbl_Rollen',
  #     'tbl_Semester', 'tbl_Spesenansätze', 'tbl_Sprachen', 'tbl_Sprachkenntnisse',
  #     'tbl_Stundenerfassung', 'tbl_Veranstaltungen', 'tbl_Veranstaltungsteilnehmer',
  #     'tbl_VerfahrensHistory', 'tbl_Verfahrensstati', 'tbl_VersionData', 'tbl_EinsatzOrte',
  #     'tbl_FreiwilligenFunktionen', 'tbl_Kursarten', 'tbl_ParameterT', 'tbl_SpracheProHauptperson'
  #   ]

  #   keys_tbl_FreiwilligenEinsätze = [
  #     :pk_FreiwilligenEinsatz, :fk_PersonenRolle, :fk_FreiwilligenFunktion, :fk_Kostenträger,
  #     :fk_EinsatzOrt, :fk_Begleitete, :fk_Kurs, :fk_Semester, :fk_Lehrmittel, :d_EinsatzVon,
  #     :d_EinsatzBis, :t_Kurzbezeichnung, :t_EinsatzOrt, :t_EinsatzAdresse, :z_FamilienBegleitung,
  #     :m_Einstiegsthematik, :m_Zielsetzung, :m_ErreichteZiele, :m_Beschreibung,
  #     :b_Probezeitbericht, :z_Spesen, :b_LP1, :b_LP2, :b_Bücher, :d_Probezeit, :d_Hausbesuch,
  #     :d_ErstUnterricht, :d_Standortgespräch, :t_Mutation, :d_MutDatum
  #   ]

  #   keys_tbl_FreiwilligenEntschädigung = [
  #     :pk_FreiwilligenEntschädigung, :fk_PersonenRolle, :fk_Semester, :z_Semesterjahr, :t_Monat,
  #     :z_Jahr, :d_Datum, :z_Einsätze, :z_Stunden, :z_Betrag, :z_Spesen, :z_Total,
  #     :t_Empfängerkonto, :z_KST, :z_AOZKonto, :t_Bemerkung, :t_Mutation, :d_MutDatum
  #   ]

    # keys_tbl_Personenrollen = [
    #   :pk_PersonenRolle, :fk_Hauptperson, :fk_Kostenträger, :z_Rolle, :d_Rollenbeginn,
    #   :d_Rollenende, :z_Familienverband, :z_AnzErw, :z_AnzKind, :m_Bemerkungen, :b_Interesse,
    #   :b_EinführungsKurs, :b_SpesenVerzicht, :t_Mutation, :d_MutDatum
    # ]

    # keys_tbl_Begleitete = [
    #   :pk_Begleitete, :fk_PersonenRolle, :fk_FamilienRolle, :t_Name, :t_Vorname, :t_Geschlecht,
    #   :z_Jahrgang, :m_Bemerkung, :t_Mutation, :d_MutDatum
    # ]

    # keys_tbl_Hauptpersonen = [
    #   :pk_Hauptperson, :t_Anrede, :t_Nachname, :t_Vorname, :t_Adresszeile1, :t_Adresszeile2,
    #   :fk_PLZ, :t_Land, :t_Telefon1, :t_Telefon2, :t_BemTel1, :t_BemTel2, :h_Email,
    #   :d_Geburtsdatum, :t_Geschlecht, :fk_Land, :t_NNummer, :d_EintrittCH, :t_Beruf,
    #   :m_Bemerkungen, :b_KlientAOZ, :t_Mutation, :d_MutDatum
    # ]

  #   keys_tbl_Journal = [
  #     :pk_Journal, :fk_Hauptperson, :fk_JournalKategorie, :fk_FreiwilligenEinsatz, :t_Dateiname,
  #     :t_Pfad, :m_Text, :t_Erfasst, :d_ErfDatum, :t_Mutation, :d_MutDatum
  #   ]
  end
end
