module FullName
  extend ActiveSupport::Concern

  included do
    def full_name
      "#{first_name} #{last_name}"
    end
  end
end
