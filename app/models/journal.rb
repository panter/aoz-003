class Journal < ApplicationRecord
  include ImportRelation

  belongs_to :user
  belongs_to :assignment, optional: true

  belongs_to :journalable, polymorphic: true, required: false

  default_scope { order(created_at: :desc) }

  CATEGORIES = [:telephone, :conversation, :email, :feedback, :file].freeze

  validates :category, presence: true

  def user
    super || User.deleted.find_by(id: user_id)
  end
end
