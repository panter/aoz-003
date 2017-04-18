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

  factory :social_worker, class: User do
    email 'socialworker@example.com'
    password 'asdfasdf'
    role 'social_worker'
  end
end
