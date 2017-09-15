FactoryGirl.define do
  factory :billing_expense do
    volunteer
    hours do |hour|
      hour.association(:hour)
    end
    user
  end
end
