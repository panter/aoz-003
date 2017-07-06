module ContactAttributes
  extend ActiveSupport::Concern

  included do
    def contact_attributes
      {
        contact_attributes:
        [
          :id, :first_name, :last_name, :_destroy, :contactable_id,
          :contactable_type, :street, :extended, :city, :postal_code,
          :primary_email, :primary_phone, :title,
          contact_emails_attributes: contact_point_attrs,
          contact_phones_attributes: contact_point_attrs
        ]
      }
    end

    def contact_point_attrs
      [:id, :body, :label, :_destroy, :type, :contacts_id]
    end
  end
end
