class Journal < ApplicationRecord
  belongs_to :user
  belongs_to :journalable, polymorphic: true, required: false

  # Categories
  TELEPHONE = 'telephone'.freeze
  CONVERSATION = 'conversation'.freeze
  EMAIL = 'email'.freeze
  FEEDBACK = 'feedback'.freeze
  FILE = 'file'.freeze

  CATEGORIES = [TELEPHONE, CONVERSATION, EMAIL, FEEDBACK, FILE].freeze

  validates :category, inclusion: { in: CATEGORIES }

  def self.category_collection
    CATEGORIES.map(&:to_sym)
  end
end
