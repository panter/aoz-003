class JournalTransform < Transformer
  def prepare_attributes(journal, person, assignment)
    {
      body: journal[:m_Text],
      journalable: person,
      assignment: assignment,
      created_at: journal[:d_ErfDatum],
      updated_at: journal[:d_MutDatum],
      category: CATEGORY_MAP[journal[:fk_JournalKategorie]],
      user: @ac_import.import_user,
      import_attributes: access_import(
        :tbl_Journal, journal[:pk_Journal], journal: journal
      )
    }
  end

  CATEGORY_MAP = {
    1 => :telephone,
    2 => :conversation,
    3 => :email,
    4 => :feedback,
    5 => :feedback
  }.freeze
end
