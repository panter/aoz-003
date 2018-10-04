FactoryBot.define do
  factory :semester_process_volunteer do
    volunteer
    semester_process

    notes { ['some note', 'another note'] }
  end
end
