class Department < ApplicationRecord
  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact

  has_and_belongs_to_many :user

  validates :contact, presence: true

  def to_s
    contact.name
  end
end
