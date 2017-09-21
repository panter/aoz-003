class GroupOfferCategory < ApplicationRecord

  before_save :default_state

  # States
  ACTIVE = 'active'.freeze
  INACTIVE = 'inactive'.freeze

  CATEGORY_STATES = [ACTIVE, INACTIVE].freeze

  def self.category_state_collection
    CATEGORY_STATES.map(&:to_sym)
  end

  private

  def default_state
    self.gategory_state ||= ACTIVE
  end
end
