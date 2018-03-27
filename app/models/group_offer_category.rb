class GroupOfferCategory < ApplicationRecord
  include ImportRelation

  has_many :group_offers
  has_and_belongs_to_many :volunteers

  CATEGORY_STATES = [:active, :inactive].freeze

  default_scope { order(:category_name) }

  scope :active, -> { where(category_state: :active) }
  scope :house_moving, -> { where('category_name LIKE ?', '%Zürich%') }
  scope :without_house_moving, -> { where.not('category_name LIKE ?', '%Zürich%') }
  scope :in_group_offer, (-> { joins(:group_offers) })

  def self.available_categories(exclude_ids)
    active.where.not(id: exclude_ids).map { |goc| [goc.category_name, goc.id] }
  end

  def self.filterable_volunteer
    active.map do |category|
      { q: :group_offer_categories_id_eq, text: category.category_name, value: category.id }
    end
  end

  def self.filterable_group_offer
    in_group_offer.active.uniq.map do |category|
      { q: :group_offer_category_id_eq, text: category.category_name, value: category.id }
    end
  end

  def to_s
    category_name
  end
end
