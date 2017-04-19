FactoryGirl.define do
  factory :user do
    sequence :email { |n| "superadmin#{n}@example.com" }
    password 'asdfasdf'
    role 'superadmin'
  end

  factory :user_with_profile, parent: :user do
    profile { |user| user.association(:profile) }
  end
end
