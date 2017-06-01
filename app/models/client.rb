class Client < ApplicationRecord
  include StateCollection

  belongs_to :user

  has_one :person, as: :personable, class_name: 'Person'
  accepts_nested_attributes_for :person

  PERMITS = ['L', 'B'].freeze

  def self.permit_collection
    PERMITS.map(&:to_sym)
  end

  def to_s
    "#{person.first_name} #{person.last_name}"
  end
end
