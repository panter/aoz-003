FactoryBot.define do
  factory :group_offer_category do
    category_name { FFaker::Skill.specialty }
    category_state 'active'
  end
end
