class EventVolunteer < ApplicationRecord
  belongs_to :event
  belongs_to :volunteer

  scope :picked, (-> { where(picked: true) })

end
