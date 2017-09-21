class GroupOffer < ApplicationRecord
  TARGET_GROUP = [:women, :men, :children, :teenagers, :unaccompanied, :all].freeze
  DURATION = [:long_term, :regular, :short_term].freeze
  OFFER_TYPES = [:internal_offer, :external_offer].freeze
  EXTERNAL_OFFER = 'external_offer'.freeze
  OFFER_STATES = [:open, :partially_occupied, :full].freeze
  VOLUNTEER_STATES = [:internal_volunteer, :external_volunteer].freeze
  VOLUNTEER_RESPONSIBLE_STATES = [:volunteer_accountable, :volunteer_member].freeze

  belongs_to :department, optional: true

  has_and_belongs_to_many :volunteers

  validates :necessary_volunteers, numericality: { greater_than: 0 }, allow_nil: true

  def external?
    offer_type == EXTERNAL_OFFER
  end
end