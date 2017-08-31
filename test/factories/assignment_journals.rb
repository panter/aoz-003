FactoryGirl.define do
  factory :assignment_journal do
    assignment
    volunteer
    association :author, factory: :user
    goals 'MyText'
    achievements 'MyText'
    future 'MyText'
    comments 'MyText'
    conversation false
  end
end
