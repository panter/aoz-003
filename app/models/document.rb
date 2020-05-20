class Document < ApplicationRecord
  has_attached_file :file

  validates :title, presence: true

  validates_attachment_presence :file
  validates_attachment_content_type :file, content_type: ['application/pdf', 'application/vnd.ms-excel', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']

  def self.categories(level = 1)
    Document.pluck('category' + level.to_i.to_s).compact.uniq.sort
  end
end
