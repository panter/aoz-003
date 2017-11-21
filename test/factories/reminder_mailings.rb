FactoryBot.define do
  factory :reminder_mailing do
    association :creator, factory: :user
    body { Faker::Lorem.paragraph }
    subject { Faker::Lorem.sentence }
  end
end
