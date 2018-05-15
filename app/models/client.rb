class Client < ApplicationRecord
  include LanguageReferences
  include YearCollection
  include BuildContactRelation
  include ZuerichScopes
  include ImportRelation
  include AcceptanceAttributes

  enum acceptance: { accepted: 0, rejected: 1, resigned: 2 }
  enum cost_unit: { city: 0, municipality: 1, canton: 2 }

  GENDER_REQUESTS = [:no_matter, :man, :woman].freeze
  AGE_REQUESTS = [:age_no_matter, :age_young, :age_middle, :age_old].freeze
  PERMITS = [:N, :F, :'B-FL', :B, :C, :PF, :CH].freeze
  SALUTATIONS = [:mrs, :mr, :family].freeze

  belongs_to :user, -> { with_deleted }, inverse_of: 'clients'
  belongs_to :resigned_by, class_name: 'User', inverse_of: 'resigned_clients',
    optional: true
  belongs_to :involved_authority, -> { with_deleted }, class_name: 'User',
    inverse_of: 'involved_authorities', optional: true
  has_many :manager_departments, through: :user, source: :departments

  has_many :assignments, dependent: :destroy
  has_many :assignment_logs, dependent: :destroy

  has_one :contact, as: :contactable, dependent: :destroy
  accepts_nested_attributes_for :contact

  has_many :relatives, as: :relativeable, dependent: :destroy
  accepts_nested_attributes_for :relatives, allow_destroy: true

  has_many :journals, as: :journalable, dependent: :destroy
  accepts_nested_attributes_for :journals, allow_destroy: true

  validates :salutation, presence: true, inclusion: { in: SALUTATIONS.map(&:to_s) }
  validates :gender_request, inclusion: { in: GENDER_REQUESTS.map(&:to_s), allow_blank: true }
  validates :age_request, inclusion: { in: AGE_REQUESTS.map(&:to_s), allow_blank: true }
  validates :permit, inclusion: { in: PERMITS.map(&:to_s), allow_blank: true }

  validates :acceptance, exclusion: {
    in: ['resigned'],
    message:
      'Klient/in kann nicht beendet werden, solange noch ein laufendes Tandem existiert.
      Bitte sicherstellen, dass alle Einsätze komplett abgeschlossen sind.'
  }, unless: :terminatable?

  scope :with_assignments, (-> { distinct.joins(:assignments) })
  scope :with_active_assignments, (-> { with_assignments.merge(Assignment.active) })

  scope :with_inactive_assignments, lambda {
    left_outer_joins(:assignments)
      .accepted
      .where('assignments.period_end < ?', Time.zone.today)
  }

  scope :without_assignments, lambda {
    left_outer_joins(:assignments).where('assignments.id is NULL')
  }

  scope :active, lambda {
    accepted.with_active_assignments
  }

  scope :inactive, lambda {
    active_assignments = Assignment.active.where('client_id = clients.id')
    accepted.where("NOT EXISTS (#{active_assignments.to_sql})")
  }

  scope :resigned_between, lambda { |start_date, end_date|
    date_between(:resigned_at, start_date, end_date)
  }

  scope :resigned_between, lambda { |start_date, end_date|
    date_between(:resigned_at, start_date, end_date)
  }

  def terminatable?
    assignments.unterminated.none?
  end

  def self.acceptences_restricted
    acceptances.except('resigned')
  end

  def self.acceptance_collection_restricted
    acceptences_restricted.keys.map(&:to_sym)
  end

  def self.cost_unit_collection
    cost_units.keys.map(&:to_sym)
  end

  def to_s
    contact.full_name
  end

  def self.first_languages
    @first_languages ||= ['TI', 'DR', 'AR', 'FS', 'DE', 'EN'].map do |lang|
      [I18n.t("language_names.#{lang}"), lang]
    end
  end

  def german_missing?
    language_skills.german.blank?
  end

  # allow ransack to use defined scopes
  def self.ransackable_scopes(auth_object = nil)
    ['active', 'inactive']
  end

  def active?
    accepted? && assignments.active.any?
  end

  def inactive?
    accepted? && assignments.active.blank?
  end
end
