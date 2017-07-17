FactoryGirl.define do
  factory :creator, class: 'User' do
    sequence :email { |n| "creator_#{n}@example.com" }
    password 'asdfasdf'
    role 'superadmin'
  end
end
