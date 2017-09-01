FactoryGirl.define do
  factory :billing_expense do
    volunteer
    user
    amount 50
  end
end
