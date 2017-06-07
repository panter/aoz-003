FactoryGirl.define do
  factory :profile do
    user
    contact do |c|
      c.association(:contact)
    end
    monday true
    tuesday true
    wednesday false
    thursday true
    friday false
  end
end
