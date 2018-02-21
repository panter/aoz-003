class EventVolunteer < ApplicationRecord
  belongs_to :event
  belongs_to :volunteer
  belongs_to :creator, -> { with_deleted }, class_name: 'User', optional: true,
    inverse_of: 'event_volunteers'

  scope :picked, (-> { where(picked: true) })

end
