class ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def user_is_in?
    user.present?
  end

  def deny_all?
    false
  end

  def show?
    scope.where(id: record.id).exists?
  end

  alias_method :index?,   :deny_all?
  alias_method :new?,     :deny_all?
  alias_method :create?,  :deny_all?
  alias_method :edit?,    :deny_all?
  alias_method :update?,  :deny_all?
  alias_method :destroy?, :deny_all?

  alias_method :home?,    :user_is_in?

  def scope
    Pundit.policy_scope!(user, record.class)
  end
end
