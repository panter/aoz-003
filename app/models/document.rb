class Document < ApplicationRecord
  has_attached_file :attachment,
  path: ':rails_root/public/system/:attachment/:id/:style/:filename',
  url: '/system/:attachment/:id/:style/:filename'

  validates_attachment :attachment, content_type: {
    content_type: [
      'application/pdf',
      'application/vnd.ms-excel',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    ]
}

  def self.categories(level = 0)
    Document.pluck('category'+level.to_i.to_s).compact.uniq.sort
  end

end
