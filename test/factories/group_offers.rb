FactoryGirl.define do
  factory :group_offer do
    title 'MyString'
    necessary_volunteers 5
    association :responsible, factory: :volunteer
  end
end
