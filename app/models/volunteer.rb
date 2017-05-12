class Volunteer < ApplicationRecord
  acts_as_paranoid

  validates :first_name, :last_name, :email, presence: true
end
