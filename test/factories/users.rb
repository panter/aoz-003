FactoryGirl.define do
  factory :user do
    email 'superadmin@example.com'
    password 'asdfasdf'
    role 'superadmin'
  end
  factory :profileless, class: User do
    email 'newuser@example.com'
    password 'asdfasdf'
    role 'superadmin'
  end
end
