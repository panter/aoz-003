module ContactAttributes
  extend ActiveSupport::Concern

  included do
    def contact_attributes
      {
        contact_attributes:
        [
          :id, :first_name, :last_name, :_destroy, :contactable_id,
          :contactable_type, :street, :extended, :city, :postal_code,
          :primary_email, :primary_phone, :title
        ]
      }
    end
  end
end
