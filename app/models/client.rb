class Client < ApplicationRecord
  include AssociatableFields
  include FullName
  include StateCollection

  include StateCollection
  include GenderCollection

  belongs_to :user

  validates :first_name, :last_name, presence: true
end
