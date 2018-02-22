class EventVolunteer < ApplicationRecord
  belongs_to :event
  belongs_to :volunteer
  belongs_to :creator, -> { with_deleted }, class_name: 'User', inverse_of: 'event_volunteers'
end
