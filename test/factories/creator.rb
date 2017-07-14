FactoryGirl.define do
  factory :creator, class: 'User' do
    sequence :email { |n| "superadmin_#{n}@example.com" }
    password 'asdfasdf'
    role 'superadmin'
  end
end
