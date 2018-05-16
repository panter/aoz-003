FactoryBot.define do
  factory :profile do
    flexible false
    morning false
    afternoon false
    evening true
    workday true
    weekend false

    contact
    association :user, profile: nil
  end
end
