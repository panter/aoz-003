FactoryBot.define do
  factory :email_template do
    subject 'MyString'
    body 'MyText'
    kind 1
    active false
  end
end
