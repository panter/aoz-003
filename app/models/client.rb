class Client < ApplicationRecord
  include AssociatableFields
  include StateCollection

  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact

  belongs_to :user
end
