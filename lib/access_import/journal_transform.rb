require 'acc_utils'

class JournalTransform
  include AccUtils

  def initialize(*accessors)
    accessors.each do |accessor|
      instance_variable_set("@#{accessor.class.name.underscore}", accessor)
    end
  end

  def prepare_attributes(journal, person, assignment)

    {
      import_attributes: access_import(
        :tbl_Journal, journal[:pk_Journal], journal: journal
      )
    }
  end
end
