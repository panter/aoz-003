FactoryGirl.define do
  factory :hour do
    assignment
    volunteer
    meeting_date '2017-08-16'
    hours 1
    minutes 30
    activity 'MyString'
    comments 'MyString'
  end
end
