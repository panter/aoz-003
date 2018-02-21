class Profile < ApplicationRecord
  include BuildContactRelation

  has_one :contact, -> { with_deleted }, as: :contactable
  accepts_nested_attributes_for :contact

  belongs_to :user, -> { with_deleted }

  has_attached_file :avatar, styles: { thumb: '100x100#' }

  validates_attachment :avatar, content_type: {
    content_type: /\Aimage\/.*\z/
  }
end
