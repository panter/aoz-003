class Profile < ApplicationRecord
  include BuildContactRelation

  has_one :contact, as: :contactable, required: true, autosave: true
  accepts_nested_attributes_for :contact

  belongs_to :user

  has_attached_file :avatar, styles: { thumb: '100x100#' }

  validates_attachment :avatar, content_type: {
    content_type: /\Aimage\/.*\z/
  }
end
