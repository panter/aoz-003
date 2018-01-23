class Department < ApplicationRecord
  include BuildContactRelation
  include ImportRelation

  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact

  has_and_belongs_to_many :user, -> { with_deleted }

  has_many :group_offers, dependent: :destroy

  validates :contact, presence: true

  scope :with_group_offer, lambda {
    joins(:group_offers).where('group_offers.department_id IS NOT NULL')
  }

  def self.filterable
    with_group_offer.uniq.map do |department|
      { q: :department_id_eq, text: department.to_s, value: department.id }
    end
  end

  def to_s
    contact.to_s
  end
end
