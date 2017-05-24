class Client < ApplicationRecord
  include AssociatableFields
  include FullName

  belongs_to :user

  validates :first_name, :last_name, presence: true
end
