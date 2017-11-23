class Manual < ApplicationRecord

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

  belongs_to :user, -> { with_deleted }

  #TODO: rename categories
  CATEGORY1 = 'category1'.freeze
  CATEGORY2 = 'category2'.freeze
  CATEGORY3 = 'category3'.freeze
  CATEGORY4 = 'category4'.freeze
  CATEGORIES = [CATEGORY1, CATEGORY2, CATEGORY3, CATEGORY4].freeze
end
