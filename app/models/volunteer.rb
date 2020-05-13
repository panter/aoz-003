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
  HOW_HAVE_YOU_HEARD_OF_AOZS = %i[internet_research friends announcment flyer].freeze

  enum acceptance: { undecided: 0, invited: 1, accepted: 2, rejected: 3, resigned: 4 }

  has_one :contact, as: :contactable, dependent: :destroy
  accepts_nested_attributes_for :contact

  delegate :primary_email, to: :contact
  delegate :full_name, to: :contact

  belongs_to :user, -> { with_deleted }, inverse_of: 'volunteer', optional: true
  belongs_to :registrar, -> { with_deleted }, class_name: 'User', foreign_key: 'registrar_id', optional: true,
    inverse_of: :volunteers
  belongs_to :reactivated_by, -> { with_deleted }, class_name: 'User', inverse_of: 'reactivated_volunteers',
    optional: true
  belongs_to :department, optional: true
  belongs_to :secondary_department, class_name: 'Department', optional: true

  # accepance updating person
  belongs_to :invited_by, -> { with_deleted }, class_name: 'User', optional: true
  belongs_to :accepted_by, -> { with_deleted }, class_name: 'User', optional: true
  belongs_to :resigned_by, -> { with_deleted }, class_name: 'User', optional: true
  belongs_to :rejected_by, -> { with_deleted }, class_name: 'User', optional: true
  belongs_to :undecided_by, -> { with_deleted }, class_name: 'User', optional: true
  belongs_to :created_by, -> { with_deleted }, class_name: 'User', foreign_key: 'registrar_id', optional: true

  has_one :registrar_department, through: :registrar

  has_many :departments, through: :group_offers

  has_many :hours, dependent: :destroy

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
  validates_presence_of :iban, :bank, if: -> { validate_waive_and_bank && waive.blank? }
  validates :salutation, presence: true
  validates_attachment :avatar, content_type: {
    content_type: /\Aimage\/.*\z/
  }

  validates :user, absence: true,
    if: :external?,
    unless: :user_deleted?

  # allot of old records would cause app to crash if validation would run for them
  # so we need to omit it for them
  def requires_birth_year?
    new_record? || created_at >= Date.new(2020, 5, 5)
  end
  validates :birth_year, presence: true, if: :requires_birth_year?

  attr_accessor :validate_waive_and_bank

  scope :order_lastname, lambda {
    joins(:contact).order('contacts.last_name ASC')
  }

  scope :process_eq, lambda { |process|
    return unless process.present?
    return joins(:user).merge(User.with_pending_invitation) if process == 'havent_logged_in'
    where(acceptance: process)
  }
  scope :invited_but_never_logged_in, lambda {
    joins(:user).merge(User.with_pending_invitation)
  }

  scope :with_assignments, (-> { joins(:assignments) })
  scope :with_group_assignments, (-> { joins(:group_assignments) })
  scope :without_assignment, (-> { left_outer_joins(:assignments).where(assignments: { id: nil }) })

  scope :without_group_assignments, lambda {
    left_outer_joins(:group_assignments).where(group_assignments: { id: nil })
  }

  scope :with_active_assignments, (-> { joins(:assignments).merge(Assignment.active) })

  scope :not_in_any_group_offer, lambda {
    left_joins(:group_offers).where(group_assignments: { volunteer_id: nil })
  }

  scope :with_active_assignments_between, lambda { |start_date, end_date|
    joins(:assignments).merge(Assignment.active_between(start_date, end_date))
  }

  scope :with_active_group_assignments_between, lambda { |start_date, end_date|
    joins(:group_assignments).merge(GroupAssignment.active_between(start_date, end_date))
  }

  scope :external, (-> { where(external: true) })
  scope :internal, (-> { where(external: false) })
  scope :not_resigned, (-> { where.not(acceptance: :resigned) })

  ## Semester Process Scopes
  #
  scope :have_semester_process, lambda { |semester|
    joins(semester_process_volunteers: [:semester_process])
      .where(
        'semester_processes.semester && daterange(?,?)',
        semester.begin.advance(days: 1), semester.end.advance(days: -1)
      )
  }

  scope :have_mission, lambda {
    left_joins(:assignments).left_joins(:group_assignments)
      .where('assignments.period_start IS NOT NULL OR group_assignments.period_start IS NOT NULL')
      .group('volunteers.id')
  }

  def self.semester_process_eligible(semester)
    joins(:contact).where.not(id: have_semester_process(semester).ids)
      .active_semester_mission(semester)
  end

  def self.feedback_overdue(semester)
    joins(:contact).where(id: have_semester_process(semester).where("semester_process_volunteers.commited_at IS NULL").ids)
  end

  def unsubmitted_semester_feedbacks
    semester_process_volunteers.unsubmitted
  end

  def submitted_semester_feedbacks
    semester_process_volunteers.submitted
  end

  def unsubmitted_semester_feedbacks?
    semester_process_volunteers.unsubmitted.any?
  end

  def submitted_semester_feedbacks_covers_semester?(selected_billing_semester)
    submitted_semester_feedbacks.in_semester(selected_billing_semester).any?
  end

  def unsubmitted_semester_feedbacks_covers_semester?(selected_billing_semester)
    unsubmitted_semester_feedbacks.in_semester(selected_billing_semester).any?
  end

  ## Activness Scopes
  #
  scope :will_take_more_assignments, (-> { where(take_more_assignments: true) })

  scope :activeness_not_ended, lambda {
    where('volunteers.activeness_might_end IS NULL OR volunteers.activeness_might_end >= ?', Date.current)
  }
  scope :activeness_ended, lambda {
    where(active: true)
      .where('volunteers.activeness_might_end IS NOT NULL AND volunteers.activeness_might_end < ?',
        Time.zone.today)
  }
  scope :active, lambda {
    accepted.activeness_not_ended.where(active: true)
  }

  scope :is_active_group_or_assignment, lambda {
    accepted.activeness_not_ended.where(active: true)
  }
  scope :is_active_on_group_and_assignment, lambda {
    accepted.is_active_assignment.is_active_group
  }
  scope :is_inactive_group_and_assignment, lambda {
    accepted.where(active: false).or(
      accepted.activeness_ended
    )
  }

  scope :activeness_not_ended_assignment, lambda {
    accepted.where('volunteers.activeness_might_end_assignments IS NULL OR volunteers.activeness_might_end_assignments > ?', Date.current)
  }
  scope :activeness_ended_assignment, lambda {
    where(active_on_assignment: true)
      .where('volunteers.activeness_might_end_assignments IS NOT NULL')
      .where('volunteers.activeness_might_end_assignments < ?', Date.current)
  }
  scope :is_active_assignment, lambda {
    accepted.where(active_on_assignment: true).activeness_not_ended_assignment
  }
  scope :is_inactive_assignment, lambda {
    accepted.where(active_on_assignment: false).or(
      accepted.activeness_ended_assignment
    )
  }

  scope :activeness_not_ended_group, lambda {
    where('volunteers.activeness_might_end_groups IS NULL').or(
      where('volunteers.activeness_might_end_groups >= ?', Date.current)
    )
  }
  scope :activeness_ended_group, lambda {
    where(active_on_group: true)
      .where('volunteers.activeness_might_end_groups IS NOT NULL')
      .where('volunteers.activeness_might_end_groups < ?', Date.current)
  }
  scope :is_active_group, lambda {
    accepted.where(active_on_group: true).activeness_not_ended_assignment
  }
  scope :is_inactive_group, lambda {
    accepted.where(active_on_group: false).or(
      accepted.activeness_ended_group
    )
  }

  scope :seeking_assignment_client, lambda {
    internal.accepted.where(active_on_assignment: false).or(
      internal.accepted.activeness_ended_assignment
    )
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

  def self.active_semester_mission(semester)
    volunteers = Volunteer.have_mission
    prob = semester.end.advance(weeks: -4)
    vol_with_missions = volunteers.select do |v|
      [v.assignments, v.group_assignments].detect do |mission|
        mission.where("period_end IS NULL").where("period_start < ?", prob).any?
      end
    end
    vol_with_missions
  end

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

  scope :in_department_or_secondary_department, lambda { |department = nil|
    return all unless department

    where(department: department).or(
      where(secondary_department: department)
    )
  }

  def self.ransackable_scopes(auth_object = nil)
    %w[
      active
      inactive
      not_resigned
      invited_but_never_logged_in
      is_active_group_or_assignment
      is_active_on_group_and_assignment
      is_inactive_group_and_assignment
      is_active_assignment
      is_inactive_assignment
      is_active_group
      is_inactive_group
    ]
  end

  def verify_and_update_state
    assignment_max = relevant_period_end_max_assignment
    groups_max = relevant_period_end_max_group
    update(active: active?,
           activeness_might_end: global_active_end(assignment_max, groups_max),
           active_on_assignment: active_assignments?,
           activeness_might_end_assignments: assignment_max,
           active_on_group: active_groups?,
           activeness_might_end_groups: groups_max)
  end

  def global_active_end(assignment_max, groups_max)
    if assignments.active.no_end.any? || group_assignments.active.no_end.any?
      nil
    else
      [assignment_max, groups_max].compact.max
    end
  end

  def relevant_period_end_max_assignment
    active_assignment_end_dates.max if assignments.end_in_future.any?
  end

  def relevant_period_end_max_group
    active_group_assignment_end_dates.max if group_assignments.end_in_future.any?
  end

  def active?
    active_assignments? || active_groups?
  end

  def active_assignments?
    accepted? && assignments.active.any?
  end

  def active_groups?
    accepted? && group_assignments.active.any?
  end

  def inactive?
    accepted? && !active?
  end

  def inactive_assignments?
    accepted? && !active_assignments?
  end

  def inactive_groups?
    accepted? && !active_groups?
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
    internal? && accepted? && assignments.active.blank?
  end

  def self.first_languages
    ['DE', 'EN', 'FR', 'ES', 'IT', 'AR'].map do |lang|
      [I18n.t("language_names.#{lang}"), lang]
    end
  end

  def undecided_by
    super || registrar
  end

  def how_have_you_heard_of_aoz=(value)
    return if value.blank?
    self[:how_have_you_heard_of_aoz] = if value.is_a?(Array)
                                         value.reject(&:blank?).join(',')
                                       else
                                         value
                                       end
  end

  def how_have_you_heard_of_aoz
    self[:how_have_you_heard_of_aoz]&.split(',')&.map(&:to_sym) || []
  end

  def self.how_have_you_heard_of_aoz_collection
    HOW_HAVE_YOU_HEARD_OF_AOZS.map do |value|
      [I18n.t("activerecord.attributes.volunteer.how_have_you_heard_of_aozs.#{value}"), value]
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

  def terminate!(resigned_by)
    self.class.transaction do
      update(acceptance: :resigned, resigned_at: Time.zone.now, resigned_by: resigned_by)
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
    user.blank? && accepted?
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

  def reactivate!(user)
    update!(acceptance: 'accepted', accepted_by: user, reactivated_by: user, reactivated_at: Time.zone.now, resigned_at: nil)
    return true if external?

    if user.present? && (user.sign_in_count.zero? || !user.invitation_accepted?)
      user.invite!
    else
      self.user = User.invite!(email: contact.primary_email, role: 'volunteer')
    end
    save
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
