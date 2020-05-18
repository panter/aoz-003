FactoryBot.define do
  factory :group_offer_category do
    category_name { FFaker::Skill.unique.specialty }
    category_state { 'active' }
  end
end
