class Profile < ApplicationRecord
  include BuildContactRelation

  has_one :contact, -> { with_deleted }, as: :contactable, dependent: :destroy
  accepts_nested_attributes_for :contact

  delegate :full_name, to: :contact

  belongs_to :user, -> { with_deleted }

  has_attached_file :avatar, styles: { thumb: '100x100#' }

  validates_attachment :avatar, content_type: {
    content_type: /\Aimage\/.*\z/
  }
end
