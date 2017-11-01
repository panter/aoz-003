FactoryBot.define do
  factory :group_offer_category do
    sequence :category_name do |n|
      "category #{n}"
    end
    category_state 'active'
  end
end
