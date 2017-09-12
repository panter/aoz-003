class Journal < ApplicationRecord
  include ImportRelation

  belongs_to :user
  belongs_to :journalable, polymorphic: true, required: false

  belongs_to :assignment, required: false

  default_scope { order(created_at: :desc) }

  CATEGORIES = [:telephone, :conversation, :email, :feedback, :file].freeze

  validates :category, presence: true
end
