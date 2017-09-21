class Volunteer < ApplicationRecord
  include LanguageReferences
  include SalutationCollection
  include BuildContactRelation
  include YearCollection
  include ZuerichScopes
  include ImportRelation
  include FullBankDetails

  before_validation :handle_external
  before_save :record_acceptance_changed

  enum acceptance: [:undecided, :accepted, :rejected, :resigned]

  belongs_to :user, -> { with_deleted }, optional: true
  belongs_to :registrar, optional: true, class_name: 'User', foreign_key: 'registrar_id'

  has_many :certificates

  has_one :contact, as: :contactable, dependent: :destroy
  accepts_nested_attributes_for :contact

  delegate :primary_email, to: :contact
  delegate :full_name, to: :contact

  has_many :journals, as: :journalable, dependent: :destroy
  accepts_nested_attributes_for :journals, allow_destroy: true

  has_many :assignments, dependent: :destroy
  has_many :clients, through: :assignments

  has_many :hours, through: :assignments

  has_many :assignment_journals, through: :assignments
  has_many :billing_expenses
  has_many :reminders, dependent: :destroy

  has_and_belongs_to_many :group_offers

  has_attached_file :avatar, styles: { thumb: '100x100#' }

  validates :contact, presence: true
  validates :salutation, presence: true
  validates_attachment :avatar, content_type: {
    content_type: /\Aimage\/.*\z/
  }

  default_scope { order(created_at: :desc) }

  scope :created_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }
  scope :created_before, ->(max_time) { where('volunteers.created_at < ?', max_time) }
  scope :created_after, ->(min_time) { where('volunteers.created_at > ?', min_time) }

  scope :with_hours, (-> { joins(:hours).distinct })

  scope :all_accepted, (-> { where(acceptance: :accepted) })
  scope :all_resigned, (-> { where(acceptance: :resigned) })
  scope :all_rejected, (-> { where(acceptance: :rejected) })
  scope :all_undecided, (-> { where(acceptance: :undecided) })

  scope :with_assignments, (-> { joins(:assignments).distinct })
  scope :with_active_assignments, (-> { joins(:assignments).merge(Assignment.active).distinct })
  scope :with_active_assignments_between, lambda { |start_date, end_date|
    joins(:assignments).merge(Assignment.active_between(start_date, end_date)).distinct
  }
  scope :without_assignment, (-> { left_outer_joins(:assignments).where(assignments: { id: nil }) })
  scope :without_active_assignment, (-> { joins(:assignments).merge(Assignment.ended) })
  scope :not_responsible, (-> { where.not(id: GroupOffer.pluck(:responsible_id)) })
  scope :not_in_any_group_offer, lambda {
    left_joins(:group_offers).where(group_offers_volunteers: { volunteer_id: nil })
  }
  scope :with_inactive_assignments, (-> { joins(:assignments).merge(Assignment.inactive).distinct })


  scope :external, (-> { where(external: true) })
  scope :internal, (-> { where(external: false) })
  scope :will_take_more_assignments, (-> { where(take_more_assignments: true) })

  scope :seeking_clients, lambda {
    all_inactive + all_active.will_take_more_assignments
  }
  scope :all_active, (-> { all_accepted.with_active_assignments })
  scope :all_inactive, lambda {
    all_accepted.without_assignment + all_accepted.with_inactive_assignments
  }

  def active?
    accepted? && assignments.active.any?
  end

  def inactive?
    accepted? && assignments.active.blank?
  end

  def handle_external
    contact.external = true if external
  end

  def hours_sum
    hours.sum(&:hours) + hours.sum(&:minutes) / 60
  end

  def minutes_sum
    hours.sum(&:minutes) % 60
  end

  def assignment_kinds
    has_kinds = assignments.map(&:kind).uniq
    Assignment::KINDS.map { |kind| [kind.to_sym, has_kinds.include?(kind.to_s)] }.to_h
  end

  def assignments_duration
    {
      duration_start: assignments.minimum(:period_start),
      duration_end: assignments.maximum(:period_end)
    }
  end

  def assignments?
    assignments.size.positive?
  end

  def external?
    external
  end

  def internal?
    !external
  end

  def internal_and_assignments?
    internal? && assignments?
  end

  def self_applicant?
    registrar.blank?
  end

  def seeking_clients?
    accepted? && inactive? || take_more_assignments && active?
  end

  def self.acceptance_collection
    acceptances.keys.map(&:to_sym)
  end

  SINGLE_ACCOMPANIMENTS = [:man, :woman, :family, :kid, :unaccompanied].freeze
  GROUP_ACCOMPANIMENTS = [:sport, :creative, :music, :culture, :training, :german_course,
                          :dancing, :health, :cooking, :excursions, :women, :teenagers,
                          :children, :other_offer].freeze
  REJECTIONS = [:us, :her, :other].freeze
  AVAILABILITY = [:flexible, :morning, :afternoon, :evening, :workday, :weekend].freeze

  def self.first_languages
    ['DE', 'EN', 'FR', 'ES', 'IT', 'AR'].map do |lang|
      [I18nData.languages(I18n.locale)[lang], lang]
    end
  end

  def to_s
    "#{contact.first_name} #{contact.last_name}"
  end

  private

  def record_acceptance_changed
    self["#{acceptance_change[1]}_at".to_sym] = Time.zone.now if acceptance_changed?
  end
end
