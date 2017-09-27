class GroupOfferCategory < ApplicationRecord
  has_many :group_offers

  CATEGORY_STATES = [:active, :inactive].freeze
end
