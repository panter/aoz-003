FactoryGirl.define do
  factory :group_offer do
    association :creator, factory: :user
    group_offer_category
    title { Faker::Lorem.sentence }
    necessary_volunteers 5
  end
end
