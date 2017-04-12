FactoryGirl.define do
  factory :user do
    email 'superadmin@example.com'
    password 'asdfasdf'
    role 'superadmin'
  end

  factory :user_noprofile, class: User do
    email 'noprofile@example.com'
    password 'asdfasdf'
    role 'superadmin'
  end
end
