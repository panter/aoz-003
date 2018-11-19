class SemesterProcessVolunteerMission < ApplicationRecord
  include MissionEitherOneRelation

  delegate :volunteer, to: :semester_process_volunteer
  belongs_to :semester_process_volunteer
end
