class Client < ApplicationRecord
  include AssociatableFields
  include FullName
  include StateCollection

  belongs_to :user
  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact
end
