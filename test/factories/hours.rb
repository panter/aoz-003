FactoryGirl.define do
  factory :hour do
    volunteer
    meeting_date Faker::Date.between(300.days.ago, 10.days.ago)
    hours Faker::Number.between(1, 5)
    minutes [0, 15, 30, 45].sample
    activity 'MyString'
    comments 'MyString'
  end
end
