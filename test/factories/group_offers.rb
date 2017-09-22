FactoryGirl.define do
  factory :group_offer do
    title 'MyString'
    necessary_volunteers 5
    association :responsible, factory: :volunteer
    group_offer_category
  end
end
