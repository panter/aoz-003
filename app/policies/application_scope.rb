class ApplicationScope
  attr_reader :user, :scope

  def initialize(user, scope)
    @user = user
    @scope = scope
  end

  delegate :superadmin?, to: :user
  delegate :department_manager?, to: :user
  delegate :social_worker?, to: :user
  delegate :volunteer?, to: :user

  delegate :all, to: :scope

  def resolve_owner
    scope.where(user: user)
  end

  def resolve_assignment
    scope.joins(:assignment)
  end

  def resolve_author_and_assignment
    scope.joins(:assignment).where(author: user)
  end
end
