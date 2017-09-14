class Department < ApplicationRecord
  include BuildContactRelation
  include ImportRelation

  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact

  has_and_belongs_to_many :user, -> { with_deleted }

  validates :contact, presence: true

  def to_s
    contact.last_name
  end
end
