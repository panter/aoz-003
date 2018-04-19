class Department < ApplicationRecord
  include BuildContactRelation
  include ImportRelation

  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact

  has_and_belongs_to_many :user, -> { with_deleted }

  has_many :events, dependent: :destroy
  has_many :group_offers, dependent: :destroy
  has_many :volunteers_group_offer, through: :group_offers, source: :volunteers
  has_many :volunteers_registrar, through: :user, source: :volunteers

  validates :contact, presence: true

  scope :with_group_offer, lambda {
    joins(:group_offers).where('group_offers.department_id IS NOT NULL')
  }
  scope :name_asc, lambda {
    joins(:contact).order('contacts.last_name ASC')
  }
  scope :name_desc, lambda {
    joins(:contact).order('contacts.last_name DESC')
  }

  def self.filterable
    with_group_offer.uniq.map do |department|
      { q: :department_id_eq, text: department.to_s, value: department.id }
    end
  end

  delegate :to_s, to: :contact
end
