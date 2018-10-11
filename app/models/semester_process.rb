class SemesterProcess < ApplicationRecord
  belongs_to :creator, -> { with_deleted }, class_name: 'User', inverse_of: 'semester_processes'
end
