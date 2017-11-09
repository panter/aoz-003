class GroupOfferCategory < ApplicationRecord
  has_many :group_offers
  has_and_belongs_to_many :volunteers

  CATEGORY_STATES = [:active, :inactive].freeze

  scope :active, -> { where(category_state: :active) }

  def to_s
    category_name
  end
end
