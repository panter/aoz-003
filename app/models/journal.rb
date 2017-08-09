class Journal < ApplicationRecord
  belongs_to :user
  belongs_to :journalable, polymorphic: true, required: false

  CATEGORIES = [:telephone, :conversation, :email, :feedback, :file].freeze

  validates :category, presence: true
end
