class Contact < ApplicationRecord
  belongs_to :contactable, polymorphic: true, optional: true

  validates :last_name, presence: true, if: :validate_last_name?
  validates :first_name, presence: true, if: :validate_first_name?

  validates :primary_email, presence: true, if: :needs_primary_email?
  validates :primary_phone, presence: true, if: :needs_primary_email?

  validates :street, :postal_code, :city, presence: true, if: :needs_primary_email?

  def to_s
    last_name
  end

  def full_name
    "#{try(:first_name)} #{last_name}"
  end

  def full_city
    "#{postal_code} #{city}"
  end

  def full_address
    [street, extended, postal_code, city].reject(&:blank?).join(', ')
  end

  def needs_primary_email?
    ['Client', 'Volunteer'].include? contactable_type
  end

  def validate_first_name?
    !department? && !profile?
  end

  def validate_last_name?
    !profile?
  end

  def profile?
    contactable_type == 'Profile'
  end

  def department?
    contactable_type == 'Department'
  end

  def volunteer?
    contactable_type == 'Volunteer'
  end
end
