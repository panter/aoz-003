class Client < ApplicationRecord
  include AssociatableFields

  belongs_to :user

  validates :first_name, :last_name, presence: true
end
