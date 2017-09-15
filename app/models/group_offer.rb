class GroupOffer < ApplicationRecord
  belongs_to :department, optional: true

  validates :necessary_volunteers, numericality: { greater_than: 0 }, allow_nil: true

  def self.target_collection
    [:women, :men, :children, :teenagers, :unaccompanied, :all]
  end

  def self.duration_collection
    [:long_term, :regular, :short_term]
  end

  INTERNAL_OFFER = 'internal_offer'.freeze
  EXTERNAL_OFFER = 'external_offer'.freeze
  OFFER_STATES = [INTERNAL_OFFER, EXTERNAL_OFFER].freeze

  INTERNAL_VOLUNTEER = 'internal_volunteer'.freeze
  EXTERNAL_VOLUNTEER = 'external_volunteer'.freeze
  VOLUNTEER_STATES = [INTERNAL_VOLUNTEER, EXTERNAL_VOLUNTEER].freeze

  VOLUNTEER_ACCOUNTABLE = 'volunteer_accountable'.freeze
  VOLUNTEER_MEMBER = 'volunteer_member'.freeze
  VOLUNTEER_RESPONSIBLE_STATES = [VOLUNTEER_ACCOUNTABLE, VOLUNTEER_MEMBER].freeze

  def self.offer_state_collection
    OFFER_STATES.map(&:to_sym)
  end

  def self.volunteer_state_collection
    VOLUNTEER_STATES.map(&:to_sym)
  end

  def self.volunteer_responsible_collection
    VOLUNTEER_RESPONSIBLE_STATES.map(&:to_sym)
  end

  def external?
    offer_state == EXTERNAL_OFFER
  end
end
