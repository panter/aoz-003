class Volunteer < ApplicationRecord
  include LanguageReferences
  include BuildContactRelation
  include YearCollection
  include ZuerichScopes
  include ImportRelation
  include FullBankDetails

  before_validation :handle_user_with_external_change, if: :external_changed?
  before_save :record_acceptance_changed
  after_update :copy_contact_to_user, if: :user_added?

  SINGLE_ACCOMPANIMENTS = [:man, :woman, :family, :kid, :unaccompanied].freeze
  REJECTIONS = [:us, :her, :other].freeze
  AVAILABILITY = [:flexible, :morning, :afternoon, :evening, :workday, :weekend].freeze
  SALUTATIONS = [:mrs, :mr].freeze

  enum acceptance: { undecided: 0, invited: 4, accepted: 1, rejected: 2, resigned: 3 }

  has_one :contact, as: :contactable, dependent: :destroy, inverse_of: :contactable
  accepts_nested_attributes_for :contact

  delegate :primary_email, to: :contact
  delegate :full_name, to: :contact

  belongs_to :user, -> { with_deleted }, inverse_of: 'volunteer', optional: true
  belongs_to :registrar, class_name: 'User', foreign_key: 'registrar_id', optional: true,
    inverse_of: :volunteers

  has_one :department, through: :registrar

  has_many :departments, through: :group_offers
  has_many :clients, through: :assignments

  has_many :hours, dependent: :destroy
  has_many :feedbacks, dependent: :destroy

  has_many :certificates

  has_many :journals, as: :journalable, dependent: :destroy, inverse_of: :journalable
  accepts_nested_attributes_for :journals, allow_destroy: true

  has_many :assignments, dependent: :destroy
  has_many :assignment_logs, dependent: :destroy
  has_many :clients, through: :assignments
  has_many :client_logs, through: :assignment_logs

  has_many :billing_expenses

  has_many :group_assignments, dependent: :delete_all
  has_many :group_assignment_logs

  has_many :group_offers, through: :group_assignments
  # categories done in group offers
  has_many :categories_from_group_assignments, through: :group_offers, source: :group_offer_category
  has_many :categories_from_group_assignment_log, through: :group_assignment_logs,
    source: :group_offer_category

  # chosen by volunteer (interested in)
  has_and_belongs_to_many :group_offer_categories

  has_many :reminder_mailing_volunteers, dependent: :delete_all
  has_many :reminder_mailings, through: :reminder_mailing_volunteers
  has_many :reminded_assignments, through: :reminder_mailing_volunteers,
    source: :reminder_mailable, inverse_of: 'reminder_mailable'

  has_attached_file :avatar, styles: { thumb: '100x100#' }

  # Validations
  #

  validates :contact, presence: true
  validates :salutation, presence: true
  validates_attachment :avatar, content_type: {
    content_type: /\Aimage\/.*\z/
  }

  validates :user, absence: true,
    if: :external?,
    unless: :user_deleted?

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
  scope :with_terminated_assignments_between, lambda { |start_date, end_date|
    joins(:assignments).merge(Assignment.terminated_between(start_date, end_date))
  }
  scope :with_active_group_assignments_between, lambda { |start_date, end_date|
    joins(:group_assignments).merge(GroupAssignment.active_between(start_date, end_date))
  }

  scope :with_active_assignments, (-> { joins(:assignments).merge(Assignment.active) })
  scope :without_assignment, (-> { left_outer_joins(:assignments).where(assignments: { id: nil }) })
  scope :without_group_offer, lambda {
    left_outer_joins(:group_offers).where(group_offers: { id: nil })
  }
  scope :without_active_assignment, lambda {
    joins(:assignments).merge(Assignment.ended)
  }
  scope :not_in_any_group_offer, lambda {
    left_joins(:group_offers).where(group_assignments: { volunteer_id: nil })
  }

  scope :external, (-> { where(external: true) })
  scope :internal, (-> { where(external: false) })
  scope :not_resigned, (-> { where.not(acceptance: :resigned) })

  scope :with_assignment_6_months_ago, lambda {
    joins(:assignments).merge(Assignment.start_before(6.months.ago))
  }

  scope :with_assignment_ca_6_weeks_ago, lambda {
    joins(:assignments).merge(Assignment.started_ca_six_weeks_ago)
  }

  scope :with_only_inactive_assignments, lambda {
    left_outer_joins(:assignments)
      .merge(Assignment.inactive)
      .where.not(assignments: { volunteer_id: with_active_assignments.ids })
  }

  scope :will_take_more_assignments, (-> { where(take_more_assignments: true) })

  scope :activeness_not_ended, lambda {
    where('volunteers.activeness_might_end IS NULL OR volunteers.activeness_might_end > ?',
      Time.zone.today)
  }
  scope :activeness_ended, lambda {
    where(active: true)
      .where('volunteers.activeness_might_end IS NOT NULL AND volunteers.activeness_might_end < ?',
        Time.zone.today)
  }
  scope :active, lambda {
    activeness_not_ended.where(active: true)
  }

  scope :inactive, lambda {
    seeking_clients
  }
  scope :seeking_clients, lambda {
    accepted.where(active: false).or(accepted.activeness_ended)
  }
  scope :seeking_clients_will_take_more, lambda {
    seeking_clients.or(accepted.will_take_more_assignments)
  }

  def verify_and_update_state
    update(active: active?, activeness_might_end: relevant_period_end_max)
  end

  def relevant_period_end_max
    # any assignment with no end means activeness is not going to end
    return nil if group_assignments.stay_active.any? || assignments.stay_active.any?
    [active_group_assignment_end_dates.max, active_assignment_end_dates.max].compact.max
  end

  def active?
    accepted? && (assignments.active.any? || group_assignments.active.any?)
  end

  def inactive?
    accepted? && assignments.active.blank? && group_assignments.active.blank?
  end

  def unterminated_assignments?
    assignments.unterminated.any?
  end

  def unterminated_group_assignments?
    group_assignments.unterminated.any?
  end

  def terminatable?
    return unterminated_assignments? if assignments.any?
    return unterminated_group_assignments? if group_assignments.any?
    true
  end

  def state
    return acceptance unless accepted?
    return :active if active?
    :inactive if inactive?
  end

  def handle_external
    contact.external = true if external
  end

  def assignment_start_dates
    assignments.where.not(period_start: nil).pluck(:period_start)
  end

  def assignment_end_dates
    assignments.where.not(period_end: nil).pluck(:period_end)
  end

  def active_assignment_end_dates
    assignments.active.where.not(period_end: nil).pluck(:period_end)
  end

  def group_assignment_start_dates
    group_assignments.where.not(period_start: nil).pluck(:period_start)
  end

  def group_assignment_end_dates
    group_assignments.where.not(period_end: nil).pluck(:period_end)
  end

  def active_group_assignment_end_dates
    group_assignments.active.where.not(period_end: nil).pluck(:period_end)
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
    assignments.started.any?
  end

  def assignment_logs_started?
    assignment_logs.started.any?
  end

  def group_assignment_started?
    group_assignments.started.any?
  end

  def group_assignment_logs_started?
    group_assignment_logs.started.any?
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

  def group_accompaniments_all_values
    GroupOfferCategory.active.map do |group|
      { title: group.category_name, value: group_offer_categories.include?(group) }
    end
  end

  def group_accompaniments_active_without_house_moving
    GroupOfferCategory.active_without_house_moving.map do |group|
      { title: group.category_name, value: group_offer_categories.include?(group) }
    end
  end

  def group_accompaniments_house_moving
    GroupOfferCategory.house_moving.map do |group|
      { title: group.category_name, value: group_offer_categories.include?(group) }
    end
  end

  def to_s
    contact.full_name
  end

  def freiwillig_gendered
    if salutation == 'mrs'
      'Freiwillige'
    elsif salutation == 'mr'
      'Freiwilliger'
    else
      'Freiwillige/r'
    end
  end

  def assignment_categories_done
    @kinds ||= create_assignments_kinds
  end

  def assignment_categories_available
    @available ||= [['Tandem', 0]] + GroupOfferCategory.available_categories(kinds_done_ids)
  end

  private

  def kinds_done_ids
    assignment_categories_done.map { |k| k[1] }
  end

  def create_assignments_kinds
    kinds = categories_from_group_assignments.map do |goc|
      [goc.category_name, goc.id]
    end + categories_from_group_assignment_log.map do |goc|
      [goc.category_name, goc.id]
    end
    kinds.push(['Tandem', 0]) if assignments.any?
    kinds.uniq
  end

  def user_added?
    saved_change_to_attribute?(:user_id)
  end

  def copy_contact_to_user
    user.profile&.contact&.update(contact.slice(:first_name, :last_name, :street, :postal_code,
      :city, :primary_phone, :secondary_phone, :primary_email))
    user.update(email: contact.primary_email)
  end

  def record_acceptance_changed
    return unless will_save_change_to_acceptance?
    self["#{acceptance_change_to_be_saved[1]}_at".to_sym] = Time.zone.now
  end

  def user_deleted?
    user&.deleted?
  end

  def external_changed?
    will_save_change_to_external?
  end

  def handle_user_with_external_change
    if external?
      contact.external = true
      user&.delete
    else
      contact.external = false
      user.restore recursive: true if user_id.present?
    end
  end

  # allow ransack to use defined scopes
  def self.ransackable_scopes(auth_object = nil)
    ['active', 'inactive', 'not_resigned']
  end
end
