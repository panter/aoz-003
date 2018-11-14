class SemesterFeedback < ApplicationRecord
  include MissionEitherOneRelation

  belongs_to :author, -> { with_deleted }, class_name: 'User', inverse_of: 'semester_feedbacks'
  belongs_to :semester_process_volunteer
  has_one :semester_process, through: :semester_process_volunteer
  has_one :volunteer, through: :semester_process_volunteer
  validates :goals, :achievements, :future, presence: true

  attr_reader :spv_mission_id

  def spv_mission_id= id
    self.mission = SemesterProcessVolunteerMission.find(id).mission
  end
end
