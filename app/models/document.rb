class Document < ApplicationRecord
  has_one_attached :file

  validates :title, presence: true

  validates :file, attached: true,
                   content_type: ext_mimes(:xls, :xlsx, :doc, :docx, :odt, :ods, :pdf)

  def self.categories(level = 1)
    Document.pluck('category' + level.to_i.to_s).compact.uniq.sort
  end
end
