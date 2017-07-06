class Contact < ApplicationRecord
  belongs_to :contactable, polymorphic: true, optional: true

  has_many :contact_emails
  accepts_nested_attributes_for :contact_emails, allow_destroy: true

  has_many :contact_phones
  accepts_nested_attributes_for :contact_phones, allow_destroy: true

  validates :last_name, presence: true
  validates :first_name, presence: true, unless: :department?

  validates :primary_email, presence: true, unless: :requires_primary_email?

  def to_s
    last_name
  end

  def full_name
    "#{try(:first_name)} #{last_name}"
  end

  def full_address
    [street, extended, postal_code, city].reject(&:blank?).join(', ')
  end

  def requires_primary_email?
    ['Department', 'Profile'].include? contactable_type
  end

  def department?
    contactable_type == 'Department'
  end
end
