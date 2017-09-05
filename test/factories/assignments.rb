FactoryGirl.define do
  factory :assignment do
    client
    volunteer
    state ['suggested', 'active'].sample
    association :creator, factory: :user
    assignment_start Faker::Date.between(500.days.ago, 200.days.ago)
    assignment_end [nil, Faker::Date.between(199.days.ago, 10.days.ago)].sample
  end
end
