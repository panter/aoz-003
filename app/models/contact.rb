class Contact < ApplicationRecord
  belongs_to :contactable, polymorphic: true, optional: true

  has_many :contact_emails
  accepts_nested_attributes_for :contact_emails, allow_destroy: true

  has_many :contact_phones
  accepts_nested_attributes_for :contact_phones, allow_destroy: true

  validates :name, presence: true, if: :department?

  def to_s
    name
  end

  def department?
    contactable_type == 'Department'
  end

  def client?
    contactable_type == 'Person'
  end

  def self.build
    Contact.new do |c|
      c.contact_emails.push ContactEmail.new
      c.contact_phones.push ContactPhone.new
    end
  end
end
