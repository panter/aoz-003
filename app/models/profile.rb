class Profile < ApplicationRecord
  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact

  belongs_to :user

  has_attached_file :avatar, styles: { thumb: '100x100#' }

  validates_attachment :avatar, content_type: {
    content_type: /\Aimage\/.*\z/
  }
end
