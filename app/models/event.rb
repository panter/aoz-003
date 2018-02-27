class Event < ApplicationRecord
  belongs_to :department, optional: true
  belongs_to :creator, -> { with_deleted }, class_name: 'User', inverse_of: 'events'

  has_many :event_volunteers, dependent: :delete_all
  accepts_nested_attributes_for :event_volunteers

  has_many :volunteers, through: :event_volunteers
  has_many :users, through: :volunteers

  enum kind: {
    intro_course: 0, professional_training: 1, professional_event: 2, theme_exchange: 3,
    volunteering: 4, german_class_managers: 5
  }

  def self.kind_collection
    kinds.keys.map(&:to_sym)
  end
end
