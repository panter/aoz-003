class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  delegate :superadmin?, to: :user, allow_nil: true
  delegate :department_manager?, to: :user
  delegate :social_worker?, to: :user
  delegate :volunteer?, to: :user

  def superadmin_or_social_worker?
    superadmin? || social_worker?
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def user_is_in?
    user.present?
  end

  def deny_all!
    false
  end

  def allow_all!
    true
  end

  def user_owns_record?
    record.user_id == user.id
  end

  def superadmin_or_record_owner?
    superadmin? || user_owns_record?
  end

  def superadmin_or_user_in_records_related?
    superadmin? || record.user_ids.include?(user.id)
  end

  def superadmin_or_volunteers_record?
    superadmin? || volunteer? && user_owns_record?
  end

  def superadmin_or_social_workers_record?
    superadmin? || social_worker? && user_owns_record?
  end

  alias_method :index?,   :deny_all!
  alias_method :new?,     :deny_all!
  alias_method :create?,  :deny_all!
  alias_method :edit?,    :deny_all!
  alias_method :update?,  :deny_all!
  alias_method :destroy?, :deny_all!

  alias_method :home?,    :user_is_in?
end
