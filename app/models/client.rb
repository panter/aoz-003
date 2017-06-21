class Client < ApplicationRecord
  after_find :generate_state_checkers
  after_initialize :generate_state_checkers
  include AssociatableFields
  include FullName
  include GenderCollection

  REGISTERED = 'registered'.freeze
  RESERVED = 'reserved'.freeze
  ACTIVE = 'active'.freeze
  FINISHED = 'finished'.freeze
  REJECTED = 'rejected'.freeze
  STATES = [REGISTERED, RESERVED, ACTIVE, FINISHED, REJECTED].freeze

  belongs_to :user

  validates :first_name, :last_name, presence: true
  validates :state, inclusion: { in: STATES }

  def self.state_collection
    STATES.map(&:to_sym)
  end

  private

  def generate_state_checkers
    STATES.each do |r|
      self.class.send(:define_method, "#{r}?".to_sym) do
        state == r
      end
    end
  end
end
