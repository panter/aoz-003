class JournalTransform < Transformer
  def prepare_attributes(journal, person, assignment)
    {
      body: journal[:m_Text],
      journalable: person,
      assignment: assignment,
      created_at: journal[:d_ErfDatum],
      updated_at: journal[:d_MutDatum],
      category: CATEGORY_MAP[journal[:fk_JournalKategorie]],
      user: @ac_import.import_user
    }.merge(import_attributes(:tbl_Journal, journal[:pk_Journal], journal: journal))
  end

  def get_or_create_by_import(access_journal_id, access_journal = nil)
    journal = Import.get_imported(Journal, access_journal_id)
    return journal if journal.present?
    local_journal = Journal.new(
      prepare_attributes(
        access_journal,
        fetch_or_import_person(access_journal),
        fetch_or_import_assignment(access_journal)
      )
    )
    local_journal.save!
    local_journal
    update_timestamps(local_journal, access_journal[:d_ErfDatum], access_journal[:d_MutDatum])
  end

  def fetch_or_import_assignment(access_journal)
    return unless access_journal[:fk_FreiwilligenEinsatz]&.positive?
    fw_einsatz = @freiwilligen_einsaetze.find(access_journal[:fk_FreiwilligenEinsatz])
    return if fw_einsatz.blank? || fw_einsatz[:fk_FreiwilligenFunktion].to_i != 1
    @ac_import.assignment_transform.get_or_create_by_import(
      access_journal[:fk_FreiwilligenEinsatz].to_i, fw_einsatz
    )
  end

  def fetch_or_import_person(access_journal)
    person = Import.find_by_hauptperson(access_journal[:fk_Hauptperson])&.importable
    return person if person.present?
    personen_rolle = @personen_rolle.find_by_hauptperson(access_journal[:fk_Hauptperson])
    if personen_rolle[:z_Rolle].to_i == EINSATZ_ROLLEN.freiwillige
      @ac_import.volunteer_transform.get_or_create_by_import(access_journal[:fk_Hauptperson], personen_rolle)
    elsif personen_rolle[:z_Rolle].to_i == EINSATZ_ROLLEN.begleitete
      @ac_import.client_transform.get_or_create_by_import(access_journal[:fk_Hauptperson], personen_rolle)
    end
  end

  def import_multiple(access_journale)
    access_journale.map do |key, access_journal|
      get_or_create_by_import(key, access_journal)
    end
  end

  def import_all(access_journale = nil)
    import_multiple(access_journale || @journale.all)
  end

  CATEGORY_MAP = {
    1 => :telephone,
    2 => :conversation,
    3 => :email,
    4 => :feedback,
    5 => :feedback
  }.freeze
end
