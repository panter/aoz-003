FactoryGirl.define do
  factory :hour do
    assignment
    volunteer
    meeting_date '2017-08-16'
    duration 1
    activity 'MyString'
    comments 'MyString'
  end
end
