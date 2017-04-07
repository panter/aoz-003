FactoryGirl.define do
  factory :user do
    email 'superadmin@example.com'
    password 'asdfasdf'
    role 'superadmin'
  end
end
