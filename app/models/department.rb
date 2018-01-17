class Department < ApplicationRecord
  include BuildContactRelation
  include ImportRelation

  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact

  has_and_belongs_to_many :user, -> { with_deleted }

  has_many :group_offers, dependent: :destroy

  validates :contact, presence: true

  def to_s
    contact.to_s
  end
end
