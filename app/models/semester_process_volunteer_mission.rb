class SemesterProcessVolunteerMission < ApplicationRecord
  include MissionEitherOneRelation

  belongs_to :semester_process_volunteer
end
