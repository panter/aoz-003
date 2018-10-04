FactoryBot.define do
  factory :semester_process_volunteer do
    volunteer
    semester_process_volunteer_missions
    hours
    semester_feedbacks
    notes { ['some note', 'another note'] }
  end
end
