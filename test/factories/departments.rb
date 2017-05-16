FactoryGirl.define do
  factory :department do
    contact do |c|
      c.association(:contact)
    end
  end
end
