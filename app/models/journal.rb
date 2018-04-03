class Journal < ApplicationRecord
  include ImportRelation

  belongs_to :user, -> { with_deleted }, inverse_of: 'journals'
  belongs_to :assignment, optional: true

  belongs_to :journalable, polymorphic: true, required: false

  CATEGORIES = [
    :telephone,
    :conversation,
    :email,
    :feedback,
    :single_accompaniment,
    :group_offer
  ].freeze

  def self.categories_filters
    CATEGORIES.map do |category|
      {
        q: 'category_eq',
        value: category,
        text: I18n.t("category.#{category}")
      }
    end
  end

  validates :category, presence: true
end
