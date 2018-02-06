class Journal < ApplicationRecord
  include ImportRelation

  belongs_to :user, -> { with_deleted }, inverse_of: 'journals'
  belongs_to :assignment, optional: true

  belongs_to :journalable, polymorphic: true, required: false

  default_scope { order(created_at: :desc) }

  CATEGORIES = [:telephone, :conversation, :email, :feedback].freeze

  validates :category, presence: true
end
