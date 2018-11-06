class SemesterProcessVolunteerMission < ApplicationRecord
  include MissionEitherOneRelation

  belongs_to :semester_process_volunteer

  attr_accessor :hour

  def hour
    @hour || Hour.new
  end
end
