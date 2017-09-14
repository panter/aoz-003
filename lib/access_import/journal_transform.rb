class JournalTransform < Transformer
  def prepare_attributes(journal, person, assignment, user_id)
    {
      body: journal[:m_Text],
      journalable_type: person.class.name,
      journalable_id: person.id,
      assignment_id: assignment&.id,
      created_at: journal[:d_ErfDatum],
      updated_at: journal[:d_MutDatum],
      category: CATEGORY_MAP[journal[:fk_JournalKategorie]],
      user_id: user_id,
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
    5 => :file
  }.freeze
end
