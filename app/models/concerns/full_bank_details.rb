module FullBankDetails
  extend ActiveSupport::Concern

  included do
    def full_bank_details
      [bank, iban].reject(&:blank?).join(', ')
    end
  end
end
