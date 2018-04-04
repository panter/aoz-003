FactoryBot.define do
  factory :billing_expense do
    user
    volunteer
    hours { [build(:hour)] }
    iban { generate :iban }

    after :build do |billing_expense|
      volunteer = billing_expense.volunteer
      if volunteer
        billing_expense.bank = volunteer.bank if volunteer.bank?
        billing_expense.iban = volunteer.iban if volunteer.iban?
      end
    end
  end
end
