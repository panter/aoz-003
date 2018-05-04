class Contact < ApplicationRecord
  before_save :update_full_name, if: :full_name_changed?, unless: :department?

  belongs_to :contactable, polymorphic: true, optional: true

  validates :last_name, presence: true, if: :validate_last_name?
  validates :first_name, presence: true, if: :validate_first_name?
  validates :primary_email, presence: true, uniqueness: true,
    format: { with: Devise.email_regexp },
    if: :needs_primary_email?

  validates :primary_phone, presence: true, if: :needs_primary_phone?
  validates :street, :postal_code, :city, presence: true, if: :needs_address?

  after_save :update_user_email, unless: :client?

  def to_s
    last_name
  end

  def full_city
    "#{postal_code} #{city}"
  end

  def full_street
    [street, extended].reject(&:blank?).join(', ')
  end

  def full_address
    [street, extended, full_city].reject(&:blank?).join(', ')
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

  def client?
    contactable_type == 'Client'
  end

  def needs_primary_email?
    !external && volunteer?
  end

  def needs_primary_phone?
    !external && volunteer? || client?
  end

  def needs_address?
    volunteer? || client?
  end

  def natural_name
    "#{first_name} #{last_name}" unless department?
  end

  def update_full_name
    self.full_name = "#{last_name}, #{first_name}"
  end

  private

  def validate_first_name?
    !department? && !profile?
  end

  def validate_last_name?
    !profile?
  end

  def full_name_changed?
    will_save_change_to_attribute?(:first_name) || will_save_change_to_attribute?(:last_name)
  end

  def update_user_email
    contactable&.user&.update(email: primary_email)
  end
end
