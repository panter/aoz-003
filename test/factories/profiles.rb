FactoryGirl.define do
  factory :profile do
    user
    first_name 'Jane'
    last_name 'Doe'
    phone '+41 44 291 22 22'
    monday true
    tuesday true
    wednesday false
    thursday true
    friday false
  end
end
