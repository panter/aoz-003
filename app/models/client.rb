class Client < ApplicationRecord
  include Reusable

  belongs_to :user

  validates :first_name, :last_name, presence: true
end
