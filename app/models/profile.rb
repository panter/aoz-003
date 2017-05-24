class Profile < ApplicationRecord
  include FullName
  belongs_to :user
  has_attached_file :avatar, styles: { thumb: '100x100#' }

  validates :first_name, :last_name, presence: true
  validates_attachment :avatar, content_type: {
    content_type: /\Aimage\/.*\z/
  }
end
