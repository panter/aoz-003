class Volunteer < ApplicationRecord
  include LanguageReferences
  include BuildContactRelation
  include YearCollection
  include ZuerichScopes
  include ImportRelation
  include FullBankDetails
  include AcceptanceAttributes
  include BillingExpenseSemesterUtils

  before_validation :handle_user_with_external_change, if: :external_changed?
  before_save :build_user_if_accepted_or_import_invited
  after_save :invite_user_if_not_invited

  SINGLE_ACCOMPANIMENTS = [:man, :woman, :family, :kid, :teenager, :unaccompanied].freeze
  REJECTIONS = [:us, :her, :other].freeze
  AVAILABILITY = [:flexible, :morning, :afternoon, :evening, :workday, :weekend].freeze
  SALUTATIONS = [:mrs, :mr].freeze

  enum acceptance: { undecided: 0, invited: 1, accepted: 2, rejected: 3, resigned: 4 }

  has_one :contact, as: :contactable, dependent: :destroy
  accepts_nested_attributes_for :contact

  delegate :primary_email, to: :contact
  delegate :full_name, to: :contact

  belongs_to :user, -> { with_deleted }, inverse_of: 'volunteer', optional: true
  belongs_to :registrar, -> { with_deleted }, class_name: 'User', foreign_key: 'registrar_id', optional: true,
    inverse_of: :volunteers
  belongs_to :department, optional: true

  has_one :registrar_department, through: :registrar

  has_many :departments, through: :group_offers

  has_many :hours, dependent: :destroy
  has_many :feedbacks, dependent: :destroy

  has_many :certificates

  has_many :journals, as: :journalable, dependent: :destroy
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

  has_many :event_volunteers, dependent: :delete_all
  has_many :events, through: :event_volunteers

  # Semester Process relations
  #

  has_many :semester_process_volunteers, dependent: :destroy
  has_many :semester_processes, through: :semester_process_volunteers
  has_many :semester_feedbacks, through: :semester_process_volunteers

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

  scope :process_eq, lambda { |process|
    return unless process.present?
    return joins(:user).merge(User.with_pending_invitation) if process == 'havent_logged_in'
    where(acceptance: process)
  }
  scope :with_hours, (-> { joins(:hours) })
  scope :with_assignments, (-> { joins(:assignments) })
  scope :with_group_assignments, (-> { joins(:group_assignments) })
  scope :without_assignment, (-> { left_outer_joins(:assignments).where(assignments: { id: nil }) })

  scope :without_group_assignments, lambda {
    left_outer_joins(:group_assignments).where(group_assignments: { id: nil })
  }

  scope :with_active_assignments, (-> { joins(:assignments).merge(Assignment.active) })

  scope :without_group_offer, lambda {
    left_outer_joins(:group_offers).where(group_offers: { id: nil })
  }

  scope :without_active_assignment, lambda {
    joins(:assignments).merge(Assignment.ended)
  }

  scope :not_in_any_group_offer, lambda {
    left_joins(:group_offers).where(group_assignments: { volunteer_id: nil })
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

  scope :external, (-> { where(external: true) })
  scope :internal, (-> { where(external: false) })
  scope :not_resigned, (-> { where.not(acceptance: :resigned) })

  scope :with_actively_registered_user, lambda {
    joins(:user).merge(User.without_deleted.signed_in_at_least_once)
  }

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
    accepted.activeness_not_ended.where(active: true)
  }

  scope :inactive, lambda {
    seeking_clients
  }
  scope :seeking_clients, lambda {
    internal.accepted.where(active: false).or(internal.accepted.activeness_ended)
  }
  scope :seeking_clients_will_take_more, lambda {
    seeking_clients.or(accepted.will_take_more_assignments)
  }

  scope :resigned_between, lambda { |start_date, end_date|
    date_between_inclusion(:resigned_at, start_date, end_date)
  }

  scope :accpted_between, lambda { |start_date, end_date|
    date_between_inclusion(:accepted_at, start_date, end_date)
  }

  scope :needs_intro_course, lambda {
    accepted.internal.where(intro_course: false)
  }

  scope :candidates_for_group_offer, lambda { |group_offer|
    volunteers = accepted
    volunteers = group_offer.internal? ? volunteers.internal : volunteers.external

    # exclude volunteers which already have a group assignment
    assignments = group_offer.group_assignments.where('volunteer_id = volunteers.id')
    volunteers.where("NOT EXISTS (#{assignments.to_sql})")
  }

  scope :need_refunds, (-> { where(waive: false) })

  def self.with_billable_hours(date = nil)
    date = billable_semester_date(date)
    need_refunds.left_joins(:contact, :hours, :billing_expenses)
      .with_billable_hours_meeting_date_semester(date)
      .with_billable_hours_no_expense_in_semester(date)
      .where('hours.billing_expense_id IS NULL')
      .where.not('hours.id IS NULL')
      .with_billable_hours_select
      .group(:id, 'contacts.full_name')
      .with_billable_hours_order
  end

  scope :with_billable_hours_meeting_date_semester, lambda { |date|
    return all if date.blank?
    where('hours.meeting_date BETWEEN :start_date AND :end_date',
      start_date: date.advance(days: 1),
      end_date: date.advance(months: BillingExpense::SEMESTER_LENGTH))
  }

  scope :with_billable_hours_no_expense_in_semester, lambda { |date|
    return all if date.blank?
    where(last_billing_expense_on: nil).or(
      where.not('volunteers.last_billing_expense_on = ?', date)
    )
  }

  scope :with_billable_hours_select, lambda {
    select(<<-SQL.squish)
      SUM(hours.hours) AS total_hours,
      contacts.full_name AS full_name,
      volunteers.*
    SQL
  }

  scope :with_billable_hours_order, lambda {
    order(<<-SQL.squish)
      (CASE
        WHEN COALESCE(volunteers.iban, '') = ''
        THEN 2
        ELSE 1
      END),
      contacts.full_name
    SQL
  }

  scope :assignable_to_department, -> { undecided.where(department_id: [nil, '']) }

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

  def terminatable?
    assignments.unterminated.none? && group_assignments.unterminated.none?
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
    internal? && (accepted? && inactive? || take_more_assignments? && active?)
  end

  def self.first_languages
    ['DE', 'EN', 'FR', 'ES', 'IT', 'AR'].map do |lang|
      [I18n.t("language_names.#{lang}"), lang]
    end
  end

  def self.process_filters
    acceptance_filters.append(
      {
        q: :acceptance_eq,
        value: 'havent_logged_in',
        text: human_attribute_name(:havent_logged_in)
      }
    ).map do |filter|
      filter[:q] = :process_eq
      filter
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
    group_assignments.map(&:group_offer).map do |group_offer|
      [group_offer.to_label, "#{group_offer.id},#{group_offer.class}"]
    end
  end

  def group_accompaniments_all_values
    GroupOfferCategory.active.map do |group|
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

  def self.ransackable_scopes(auth_object = nil)
    ['active', 'inactive', 'not_resigned', 'process_eq']
  end

  def terminate!
    self.class.transaction do
      update(acceptance: :resigned, resigned_at: Time.zone.now)
      user&.destroy
    end
  end

  def working_percent=(value)
    if value.respond_to?(:match)
      value = value.match('[0-9]+').to_s.to_i
      value = nil if value == 0
    end
    write_attribute :working_percent, value
  end

  def assignable_to_department?
    department.blank? && undecided?
  end

  def ready_for_invitation?
    internal? && user.present?
  end

  def pending_invitation?
    user.present? && !user.invitation_accepted?
  end

  def user_needed_for_invitation?
    !user.present? && accepted?
  end

  def invite_email_valid?
    invite_email&.match(Devise.email_regexp)
  end

  def invite_email
    user&.email || import&.email
  end

  def invite_user
    if ready_for_invitation?
      user.update_attribute(:email, contact.primary_email)
      user.invite!
    end
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

  def build_user_if_accepted_or_import_invited
    return unless user_invitation_needed?
    if User.exists?(email: contact.primary_email)
      return errors.add(:user, "Es existiert bereits ein User mit der Email #{contact.primary_email}!")
    end
    self.user = User.new(email: contact.primary_email, password: Devise.friendly_token, role: 'volunteer')
  end

  def user_invitation_needed?
    return if external? || user.present?
    will_save_change_to_attribute?(:acceptance, to: 'accepted') ||
      (import.present? && contact.will_save_change_to_attribute?(:primary_email))
  end

  def invite_user_if_not_invited
    # invitation go out to
    # - interal users only
    # - where there was a user account created
    # - no invitation was sent - user.invitation_sent_at.blank
    #
    # note: we used to ask here for user.invited_to_sign_up? instaed of user.invitation_sent_at.blank but
    # it lead to emails sent out twice to users that already set their password
    invite_user if user&.invitation_sent_at.blank?
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
end
