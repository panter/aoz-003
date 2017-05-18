class Contact < ApplicationRecord
  belongs_to :contactable, polymorphic: true, optional: true

  validates :name, presence: true, if: :department?

  has_many :contact_emails
  accepts_nested_attributes_for :contact_emails, allow_destroy: true
  has_many :contact_phones
  accepts_nested_attributes_for :contact_phones, allow_destroy: true

  def to_s
    name
  end

  def department?
    contactable_type == 'Department'
  end
end
