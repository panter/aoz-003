class EventVolunteer < ApplicationRecord
  belongs_to :event
  belongs_to :volunteer

  scope :picked, (-> { where(picked: true) })

  scope :kind, ->(kind) { joins(:event).where('events.kind = ?', kind) }
  scope :intro_course, (-> { kind(0) })
  scope :professional_training, (-> { kind(1) })
  scope :professional_event, (-> { kind(2) })
  scope :theme_exchange, (-> { kind(3) })
  scope :volunteering, (-> { kind(4) })
  scope :german_class_managers, (-> { kind(5) })

end
