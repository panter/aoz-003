class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable

  before_validation :assign_primary_email, if: :profile

  has_one :volunteer, dependent: :destroy

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile

  has_many :certificates
  has_many :clients
  has_many :journals
  has_many :assignments, inverse_of: 'creator'
  has_many :feedbacks, inverse_of: 'author'
  has_many :billing_expenses
  has_many :group_offers, inverse_of: 'creator'

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

  scope :department_assocable, (-> { where(role: CAN_MANAGE_DEPARTMENT) })
  scope :superadmins, (-> { where(role: SUPERADMIN) })

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

  def self.create_user_and_send_password_reset(email:, role:)
    new_user = User.new(
      email: email, password: Devise.friendly_token, role: role
    )
    new_user.save! && new_user.send_reset_password_instructions
  end

  def self.new_volunteer(volunteer)
    User.new(email: volunteer.primary_email, password: Devise.friendly_token, role: 'volunteer',
      volunteer: volunteer).save
  end

  def to_s
    email
  end

  def to_label
    if profile&.contact
      "#{full_name} #{email}"
    else
      email
    end
  end

  def full_name
    if profile&.contact
      "#{profile.contact.first_name} #{profile.contact.last_name}"
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
