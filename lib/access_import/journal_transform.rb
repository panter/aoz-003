require 'acc_utils'

class JournalTransform
  include AccUtils

  def initialize(*accessors)
    accessors.each do |accessor|
      instance_variable_set("@#{accessor.class.name.underscore}", accessor)
    end
  end

  def prepare_attributes(journal, person, assignment)
    binding.pry
    {
      body: journal[:m_Text],
      journalable_type: person.class.name,
      journalable_id: person.id,
      assignment_id: assignment&.id,
      created_at: journal[:d_ErfDatum],
      updated_at: journal[:d_MutDatum],
      category: CATEGORY_MAP[journal[:fk_JournalKategorie]],
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
