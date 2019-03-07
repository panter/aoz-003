class Journal < ApplicationRecord
  include ImportRelation

  CATEGORIES = [
    :telephone,
    :conversation,
    :email,
    :feedback,
    :single_accompaniment,
    :group_offer
  ].freeze

  belongs_to :user, -> { with_deleted }, inverse_of: 'journals'
  belongs_to :assignment, optional: true
  belongs_to :journalable, polymorphic: true, required: false

  validates :category, presence: true

  def self.categories_filters
    CATEGORIES.map do |category|
      {
        q: 'category_eq',
        value: category,
        text: I18n.t("category.#{category}")
      }
    end
  end
end
