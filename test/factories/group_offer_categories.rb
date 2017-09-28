FactoryGirl.define do
  factory :group_offer_category do
    sequence :category_name { |n| "category #{n}" }
    category_state 'active'
  end
end
