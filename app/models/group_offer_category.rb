class GroupOfferCategory < ApplicationRecord
  has_many :group_offers
  has_and_belongs_to_many :volunteers

  CATEGORY_STATES = [:active, :inactive].freeze

  scope :house_moving, -> { where('category_name LIKE ?', "%Zürich%") }
  scope :active, -> { where(category_state: :active) }
  scope :active_without_house_moving, -> { active.where.not('category_name LIKE ?', "%Zürich%") }

  def self.available_categories(exclude_ids)
    active.where.not(id: exclude_ids).map { |goc| [goc.category_name, goc.id] }
  end

  def to_s
    category_name
  end
end
