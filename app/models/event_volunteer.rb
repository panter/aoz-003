class EventVolunteer < ApplicationRecord
  before_save :set_volunteer_intro_course_true, if: :intro_course?
  before_destroy :set_volunteer_intro_course_false, if: :intro_course?

  delegate :intro_course?, to: :event

  belongs_to :event
  belongs_to :volunteer
  belongs_to :creator, -> { with_deleted }, class_name: 'User', inverse_of: 'event_volunteers'

  private

  def set_volunteer_intro_course_true
    volunteer.intro_course = true
  end

  def set_volunteer_intro_course_false
    volunteer.update(intro_course: false)
  end
end
