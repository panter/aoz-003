class Department < ApplicationRecord
  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact, allow_destroy: true

  has_and_belongs_to_many :user
end
