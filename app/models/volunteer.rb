class Volunteer < ApplicationRecord
  include LanguageReferences
  include BuildContactRelation
  include YearCollection
  include ZuerichScopes
  include ImportRelation
  include FullBankDetails

  before_validation :handle_external
  before_save :record_acceptance_changed
  before_validation :handle_user_with_external_change,
    if: :external_changed?,
    unless: proc { user_id.nil? }

  SINGLE_ACCOMPANIMENTS = [:man, :woman, :family, :kid, :unaccompanied].freeze
  GROUP_ACCOMPANIMENTS = [:sport, :creative, :music, :culture, :training, :german_course,
                          :dancing, :health, :cooking, :excursions, :women, :teenagers,
                          :children, :other_offer].freeze
  REJECTIONS = [:us, :her, :other].freeze
  AVAILABILITY = [:flexible, :morning, :afternoon, :evening, :workday, :weekend].freeze
  SALUTATIONS = [:mrs, :mr].freeze

  enum acceptance: { undecided: 0, accepted: 1, rejected: 2, resigned: 3 }

  # User with role: 'volunteer'
  belongs_to :user, -> { with_deleted }, optional: true

  # User that registered the volunteer, in case not self registered
  belongs_to :registrar, optional: true, class_name: 'User', foreign_key: 'registrar_id'
  has_one :department, through: :registrar

  has_many :departments, through: :group_offers

  has_many :assignments, dependent: :destroy
  has_many :clients, through: :assignments

  has_many :hours, dependent: :destroy
  has_many :feedbacks, dependent: :destroy

  has_many :certificates

  has_one :contact, as: :contactable, dependent: :destroy
  accepts_nested_attributes_for :contact

  delegate :primary_email, to: :contact
  delegate :full_name, to: :contact

  has_many :journals, as: :journalable, dependent: :destroy
  accepts_nested_attributes_for :journals, allow_destroy: true

  has_many :assignments, dependent: :destroy
  has_many :clients, through: :assignments

  has_many :billing_expenses
  has_many :reminders, dependent: :destroy

  has_many :group_assignments
  has_many :group_offers, through: :group_assignments
  has_many :group_assignment_logs

  has_attached_file :avatar, styles: { thumb: '100x100#' }

  validates :contact, presence: true
  validates :salutation, presence: true
  validates_attachment :avatar, content_type: {
    content_type: /\Aimage\/.*\z/
  }

  validates :user, absence: true,
    if: :external?,
    unless: proc { |user| user.deleted? }

  scope :created_between, lambda { |start_date, end_date|
    created_after(start_date).created_before(end_date)
  }
  scope :created_before, ->(max_time) { where('volunteers.created_at < ?', max_time) }
  scope :created_after, ->(min_time) { where('volunteers.created_at > ?', min_time) }

  scope :with_hours, (-> { joins(:hours) })
  scope :with_assignments, (-> { joins(:assignments) })
  scope :with_group_assignments, (-> { joins(:group_assignments) })
  scope :without_assignment, (-> { left_outer_joins(:assignments).where(assignments: { id: nil }) })
  scope :without_group_assignments, lambda {
    left_outer_joins(:group_assignments).where(group_assignments: { id: nil })
  }

  scope :with_active_assignments_between, lambda { |start_date, end_date|
    joins(:assignments).merge(Assignment.active_between(start_date, end_date))
  }
  scope :with_active_group_assignments_between, lambda { |start_date, end_date|
    joins(:group_assignments).merge(GroupAssignment.active_between(start_date, end_date))
  }

  scope :with_active_assignments, (-> { joins(:assignments).merge(Assignment.active) })
  scope :without_assignment, (-> { left_outer_joins(:assignments).where(assignments: { id: nil }) })
  scope :without_group_offer, lambda {
    left_outer_joins(:group_offers).where(group_offers: { id: nil })
  }
  scope :without_active_assignment, (-> { joins(:assignments).merge(Assignment.ended) })
  scope :not_in_any_group_offer, lambda {
    left_joins(:group_offers).where(group_assignments: { volunteer_id: nil })
  }

  scope :external, (-> { where(external: true) })
  scope :internal, (-> { where(external: false) })

  scope :with_assignment_6_months_ago, lambda {
    joins(:assignments).where('assignments.period_start < ?', 6.months.ago)
  }

  scope :with_assignment_ca_6_weeks_ago, lambda {
    joins(:assignments).where('assignments.period_start < ? AND assignments.period_start > ?',
      6.weeks.ago, 8.weeks.ago)
  }

  scope :with_only_inactive_assignments, lambda {
    left_outer_joins(:assignments)
      .merge(Assignment.inactive)
      .where.not(assignments: { volunteer_id: with_active_assignments.ids })
  }
  scope :will_take_more_assignments, (-> { where(take_more_assignments: true) })
  scope :active, (-> { accepted.with_active_assignments })

  scope :accepted_joined, (-> { accepted.left_outer_joins(:assignments) })
  scope :loj_without_assignments, (-> { accepted_joined.where(assignments: { id: nil }) })
  scope :loj_active_take_more, lambda {
    accepted_joined.will_take_more_assignments.where(assignments: { id: Assignment.active.ids })
  }

  scope :seeking_clients, lambda {
    accepted_joined
      .merge(Assignment.inactive)
      .where.not(assignments: { volunteer_id: with_active_assignments.ids })
      .or(loj_without_assignments)
  }
  scope :seeking_clients_will_take_more, lambda {
    accepted_joined
      .merge(Assignment.inactive)
      .where.not(assignments: { volunteer_id: with_active_assignments.ids })
      .or(loj_without_assignments)
      .or(loj_active_take_more)
  }

  def active?
    accepted? && (assignments.active.any? || group_assignments.ongoing.any? || group_assignments.no_end.any?)
  end

  def inactive?
    accepted? && assignments.active.blank? && group_assignments.ongoing.blank? && group_assignments.no_end.blank?
  end

  def state
    return acceptance unless accepted?
    return :active if active?
    :inactive if inactive?
  end

  def handle_external
    contact.external = true if external
  end

  def assignment_kinds
    {
      group_offer: group_offers.any?,
      assignment: assignments.any?
    }
  end

  def assignment_start_dates
    assignments.select('period_start').where.not(period_start: nil).map(&:period_start)
  end

  def assignment_end_dates
    assignments.select('period_end').where.not(period_end: nil).map(&:period_end)
  end

  def group_assignment_start_dates
    group_assignments.select('period_start').where.not(period_start: nil).map(&:period_start)
  end

  def group_assignment_end_dates
    group_assignments.select('period_end').where.not(period_end: nil).map(&:period_end)
  end

  def min_assignment_date
    (assignment_start_dates + group_assignment_start_dates).min
  end

  def max_assignment_date
    (assignment_end_dates + group_assignment_end_dates).max
  end

  def assignments?
    assignments.size.positive?
  end

  def assignment_started?
    assignments.started.size.positive?
  end

  def group_assignment_started?
    group_assignments.started.size.positive?
  end

  def external?
    external
  end

  def internal?
    !external
  end

  def internal_and_started_assignments?
    internal? && (assignment_started? || group_assignment_started?)
  end

  def self_applicant?
    registrar.blank?
  end

  def seeking_clients?
    accepted? && inactive? || take_more_assignments? && active?
  end

  def self.acceptance_collection
    acceptances.keys.map(&:to_sym)
  end

  def self.first_languages
    ['DE', 'EN', 'FR', 'ES', 'IT', 'AR'].map do |lang|
      [I18nData.languages(I18n.locale)[lang], lang]
    end
  end

  def assignment_group_offer_collection
    assignments_hour_form_collection + group_offers_form_collection
  end

  def assignments_hour_form_collection
    assignments
      .where('period_end > ? OR period_end IS NULL', 7.months.ago)
      .map { |assignment| [assignment.to_label, "#{assignment.id},#{assignment.class}"] }
  end

  def group_offers_form_collection
    group_offers.map do |group_offer|
      [group_offer.to_label, "#{group_offer.id},#{group_offer.class}"]
    end
  end

  def to_s
    contact.full_name
  end

  private

  def record_acceptance_changed
    self["#{acceptance_change_to_be_saved[1]}_at".to_sym] = Time.zone.now if will_save_change_to_acceptance?
  end

  def external_changed?
    will_save_change_to_external?
  end

  def handle_user_with_external_change
    if external?
      user.destroy
    else
      user.restore recursive: true
    end
  end
end
