class Client < ApplicationRecord
  include LanguageReferences
  include SalutationCollection
  include YearCollection
  include BuildContactRelation

  REGISTERED = 'registered'.freeze
  RESERVED = 'reserved'.freeze
  ACTIVE = 'active'.freeze
  FINISHED = 'finished'.freeze
  REJECTED = 'rejected'.freeze
  STATES = [REGISTERED, RESERVED, ACTIVE, FINISHED, REJECTED].freeze

  belongs_to :user

  has_one :assignment
  has_one :volunteer, through: :assignments

  has_one :contact, as: :contactable
  accepts_nested_attributes_for :contact

  has_one :import, as: :importable, dependent: :destroy
  accepts_nested_attributes_for :import, allow_destroy: true

  has_many :relatives, as: :relativeable, dependent: :destroy
  accepts_nested_attributes_for :relatives, allow_destroy: true

  has_many :journals, as: :journalable, dependent: :destroy
  accepts_nested_attributes_for :journals, allow_destroy: true

  validates :state, inclusion: { in: STATES }

  default_scope { order(created_at: :desc) }
  scope :need_accompanying, lambda {
    includes(:assignment).where(assignments: { client_id: nil }).order(created_at: :asc)
  }

  scope :with_assignment, (-> { joins(:assignment) })
  scope :without_assignment, (-> { left_outer_joins(:assignment).where(assignments: { id: nil }) })

  ZURICH_ZIPS = [
    '8000', '8001', '8002', '8003', '8004', '8005', '8006', '8008', '8020', '8021', '8022', '8023',
    '8024', '8025', '8026', '8027', '8028', '8029', '8030', '8031', '8032', '8033', '8034', '8035',
    '8036', '8037', '8038', '8039', '8040', '8041', '8042', '8043', '8044', '8045', '8046', '8047',
    '8048', '8049', '8050', '8051', '8052', '8053', '8055', '8056', '8057', '8058', '8060', '8061',
    '8062', '8063', '8064', '8065', '8066', '8079', '8087', '8091'
  ].freeze

  scope :zurich, (-> { joins(:contact).where(contacts: { postal_code: ZURICH_ZIPS }) })
  scope :not_zurich, (-> { joins(:contact).where.not(contacts: { postal_code: ZURICH_ZIPS }) })

  GENDER_REQUESTS = [:no_matter, :same].freeze
  AGE_REQUESTS = [:age_no_matter, :age_young, :age_middle, :age_old].freeze
  PERMITS = [:N, :F, :'B-FL', :B, :C].freeze

  def to_s
    "#{contact.first_name} #{contact.last_name}"
  end

  def self.first_languages
    [
      [I18nData.languages(I18n.locale)['TI'], 'TI'],
      ['Dari', 'DR'],
      [I18nData.languages(I18n.locale)['AR'], 'AR'],
      ['Farsi', 'FS'],
      [I18nData.languages(I18n.locale)['DE'], 'DE'],
      [I18nData.languages(I18n.locale)['EN'], 'EN']
    ]
  end

  def self.state_collection
    STATES.map(&:to_sym)
  end
end
