class Client < ApplicationRecord
  after_find :generate_state_checkers
  after_initialize :generate_state_checkers
  include AssociatableFields
  include AssociateRelatives
  include GenderCollection
  include RequestCollection
  include YearCollection

  REGISTERED = 'registered'.freeze
  RESERVED = 'reserved'.freeze
  ACTIVE = 'active'.freeze
  FINISHED = 'finished'.freeze
  REJECTED = 'rejected'.freeze
  STATES = [REGISTERED, RESERVED, ACTIVE, FINISHED, REJECTED].freeze

  belongs_to :user

  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact

  validates :state, inclusion: { in: STATES }

  def self.state_collection
    STATES.map(&:to_sym)
  end

  private

  def generate_state_checkers
    STATES.each do |s|
      self.class.send(:define_method, "#{s}?".to_sym) do
        state == s
      end
    end
  end
end
