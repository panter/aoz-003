class GroupOffer < ApplicationRecord
  TARGET_GROUP = [:women, :men, :children, :teenagers, :unaccompanied, :all].freeze
  DURATION = [:long_term, :regular, :short_term].freeze
  OFFER_TYPES = [:internal_offer, :external_offer].freeze
  EXTERNAL_OFFER = 'external_offer'.freeze
  OFFER_STATES = [:open, :partially_occupied, :full].freeze
  VOLUNTEER_STATES = [:internal_volunteer, :external_volunteer].freeze

  belongs_to :department, optional: true
  belongs_to :group_offer_category

  has_many :group_assignments
  has_many :volunteers, through: :group_assignments

  accepts_nested_attributes_for :group_assignments, allow_destroy: true

  validates :necessary_volunteers, numericality: { greater_than: 0 }, allow_nil: true

  scope :active, (-> { where(active: true) })
  scope :archived, (-> { where(active: false) })

  scope :in_department, (-> { where.not(department_id: nil) })

  def external?
    offer_type == EXTERNAL_OFFER
  end

  def archived
    archived
  end
end
