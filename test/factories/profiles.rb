FactoryBot.define do
  factory :profile do
    flexible false
    morning false
    afternoon false
    evening true
    workday true
    weekend false

    contact
    # pass empty profile to avoid infinite loop
    user { build :user, profile: nil }
  end
end
