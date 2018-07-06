class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable

  before_validation :assign_primary_email, if: :profile

  has_one :volunteer, dependent: :nullify, inverse_of: 'user'

  has_one :profile, -> { with_deleted }, dependent: :destroy
  accepts_nested_attributes_for :profile

  ransack_alias :full_name, :profile_contact_full_name_or_volunteer_contact_full_name_or_email

  has_many :events, inverse_of: 'creator', foreign_key: 'creator_id'
  has_many :event_volunteers, inverse_of: 'creator', foreign_key: 'creator_id'
  has_many :certificates
  has_many :clients, inverse_of: 'user', foreign_key: 'user_id'
  has_many :volunteers, inverse_of: 'registrar', foreign_key: 'registrar_id'
  has_many :involved_authorities, class_name: 'Client', foreign_key: 'involved_authority_id',
    inverse_of: 'involved_authority'
  has_many :journals, inverse_of: 'user'

  has_many :assignments, inverse_of: 'creator', foreign_key: 'creator_id'
  has_many :assignment_clients, through: :assignments, source: :client
  has_many :assignment_volunteers, through: :assignments, source: :volunteer

  has_many :feedbacks, inverse_of: 'author', foreign_key: 'author_id'
  has_many :trial_feedbacks, inverse_of: 'author', foreign_key: 'author_id'
  has_many :billing_expenses

  has_many :group_offers, inverse_of: 'creator', foreign_key: 'creator_id'
  has_many :group_offer_group_assignments, through: :group_offers, inverse_of: 'group_assignments'
  has_many :group_offer_group_assignment_logs, through: :group_offers,
    inverse_of: 'group_assignment_logs'
  has_many :group_offer_volunteers, through: :group_offer_group_assignments, source: :volunteer,
    inverse_of: 'volunteer'

  has_many :reminder_mailings, inverse_of: 'creator', foreign_key: 'creator_id'
  has_many :reviewed_feedbacks, class_name: 'Feedback', foreign_key: 'reviewer_id',
    inverse_of: 'reviewer'
  has_many :responsible_feedbacks, inverse_of: 'responsible', foreign_key: 'responsible_id',
    class_name: 'Feedback'
  has_many :reviewed_trial_feedbacks, class_name: 'TrialFeedback', foreign_key: 'reviewer_id',
    inverse_of: 'reviewer'
  has_many :reviewed_hours, class_name: 'Hour', foreign_key: 'reviewer_id', inverse_of: 'reviewer'

  # Assignment termination relations
  has_many :assignment_period_ends_set, class_name: 'Assignment',
    foreign_key: 'period_end_set_by_id', inverse_of: 'period_end_set_by'
  has_many :assignment_terminations_submitted, class_name: 'Assignment',
    foreign_key: 'termination_submitted_by_id', inverse_of: 'termination_submitted_by'
  has_many :assignment_terminations_verified, class_name: 'Assignment',
    foreign_key: 'termination_verified_by_id', inverse_of: 'termination_verified_by'

  # GroupAssignment termination relations
  has_many :group_assignment_period_ends_set, class_name: 'GroupAssignment',
    foreign_key: 'period_end_set_by_id', inverse_of: 'period_end_set_by'
  has_many :group_assignment_terminations_submitted, class_name: 'GroupAssignment',
    foreign_key: 'termination_submitted_by_id', inverse_of: 'termination_submitted_by'
  has_many :group_assignment_terminations_verified, class_name: 'GroupAssignment',
    foreign_key: 'termination_verified_by', inverse_of: 'termination_verified_by'

  has_many :group_offer_period_ends_set, class_name: 'GroupOffer',
    foreign_key: 'period_end_set_by_id', inverse_of: 'period_end_set_by'
  has_many :group_offer_terminations_verified, class_name: 'GroupOffer',
    foreign_key: 'termination_verified_by_id', inverse_of: 'termination_verified_by'

  has_many :resigned_clients, class_name: 'Client', foreign_key: 'resigned_by_id',
    inverse_of: 'resigned_by'

  # Mailing process done relation
  has_many :mailing_volunteer_processes_submitted, class_name: 'ReminderMailingVolunteer',
    inverse_of: 'process_submitted_by', foreign_key: 'process_submitted_by_id'

  has_many :mailing_processes_submitted, through: :mailing_volunteer_processes_submitted,
    source: :process_submitted_by

  has_and_belongs_to_many :department

  # Roles definition
  SUPERADMIN = 'superadmin'.freeze
  SOCIAL_WORKER = 'social_worker'.freeze
  DEPARTMENT_MANAGER = 'department_manager'.freeze
  VOLUNTEER = 'volunteer'.freeze

  CAN_MANAGE_DEPARTMENT = [SUPERADMIN, DEPARTMENT_MANAGER].freeze
  ROLES_FOR_USER_CREATE = [SUPERADMIN, SOCIAL_WORKER, DEPARTMENT_MANAGER].freeze

  ROLES = ROLES_FOR_USER_CREATE.dup.push(VOLUNTEER).freeze

  validates :role, inclusion: { in: ROLES }
  validates :email, uniqueness: true

  scope :department_assocable, (-> { where(role: CAN_MANAGE_DEPARTMENT) })
  scope :superadmins, (-> { where(role: SUPERADMIN) })
  scope :department_managers, (-> { where(role: DEPARTMENT_MANAGER) })
  scope :social_workers, (-> { where(role: SOCIAL_WORKER) })

  scope :signed_in_at_least_once, (-> { where.not(last_sign_in_at: nil) })
  scope :with_pending_invitation, lambda {
    where(invitation_accepted_at: nil).where.not(invitation_sent_at: nil)
  }

  def superadmin?
    role == SUPERADMIN
  end

  def department_manager?
    role == DEPARTMENT_MANAGER
  end

  def social_worker?
    role == SOCIAL_WORKER
  end

  def volunteer?
    role == VOLUNTEER
  end

  def manages_department?
    department.any?
  end

  def missing_profile?
    !volunteer? && !profile
  end

  def self.create_user_and_send_password_reset(email:, role:)
    new_user = User.new(
      email: email, password: Devise.friendly_token, role: role
    )
    new_user.save! && new_user.send_reset_password_instructions
    new_user
  end

  def self.new_volunteer(volunteer)
    User.new(email: volunteer.primary_email, password: Devise.friendly_token, role: 'volunteer',
      volunteer: volunteer).save
  end

  def to_s
    full_name
  end

  def full_name
    if profile&.contact
      "#{profile.contact.last_name}, #{profile.contact.first_name}"
    elsif volunteer?
      volunteer.contact.full_name
    else
      email
    end
  end

  def self.role_collection
    ROLES_FOR_USER_CREATE.map(&:to_sym)
  end

  protected

  def assign_primary_email
    profile.contact.primary_email = email
  end
end
