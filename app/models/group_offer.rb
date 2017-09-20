class GroupOffer < ApplicationRecord
  TARGET_GROUP = [:women, :men, :children, :teenagers, :unaccompanied, :all].freeze
  DURATION = [:long_term, :regular, :short_term].freeze
  OFFER_STATES = [:internal_offer, :external_offer].freeze
  EXTERNAL_OFFER = 'external_offer'.freeze
  VOLUNTEER_STATES = [:internal_volunteer, :external_volunteer].freeze
  VOLUNTEER_RESPONSIBLE_STATES = [:volunteer_accountable, :volunteer_member].freeze

  belongs_to :department, optional: true

  validates :necessary_volunteers, numericality: { greater_than: 0 }, allow_nil: true

  def external?
    offer_state == EXTERNAL_OFFER
  end
end
