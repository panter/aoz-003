FactoryGirl.define do
  factory :group_offer do
    title { Faker::Lorem.sentence }
    necessary_volunteers 5
    group_offer_category
  end
end
