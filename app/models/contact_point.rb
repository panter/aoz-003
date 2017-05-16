class ContactPoint < ApplicationRecord
  belongs_to :contact, optional: true

  validates :body, presence: true
end
