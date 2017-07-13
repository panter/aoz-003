FactoryGirl.define do
  factory :creator, class: 'User' do
    sequence :email { |n| "superadmin#{n}@example.com" }
    password 'asdfasdf'
    role 'superadmin'
  end
end
