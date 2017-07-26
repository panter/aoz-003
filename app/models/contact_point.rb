class ContactPoint < ApplicationRecord
  belongs_to :contact, optional: true

  validates :body, presence: true

  FORM_ATTRS = [:id, :body, :label, :_destroy, :type, :contacts_id].freeze
end
