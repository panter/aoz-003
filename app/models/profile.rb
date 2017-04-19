class Profile < ApplicationRecord
  belongs_to :user
  has_attached_file :avatar, styles: { thumb: '100x100#' }

  validates_attachment :avatar, content_type: {
    content_type: ['image/jpeg', 'image/gif', 'image/png']
  }
  validates_attachment_file_name :avatar, matches: [/png\z/, /jpe?g\z/]
  validates :first_name, :last_name, presence: true
end
