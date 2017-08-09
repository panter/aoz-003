FactoryGirl.define do
  factory :journal do
    sequence :subject { |n| "bocus subject_#{n}" }
    sequence :body { |n| " Bogus_text_body_#{n}" * 30 }
    user
    category Journal::CATEGORIES.sample
  end
end
