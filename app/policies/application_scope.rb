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

  def department_manager_or_social_worker?
    department_manager? || social_worker?
  end

  delegate :all, to: :scope
  delegate :none, to: :scope

  def resolve_owner
    scope.where(user: user)
  end

  def resolve_assignment
    scope.joins(:assignment)
  end

  def resolve_volunteer
    scope.where(volunteer: user.volunteer)
  end

  def resolve_volunteer_and_hour
    scope.joins(:hour).where(volunteer: volunteer)
  end

  def resolve_author_and_assignment
    scope.joins(:assignment).where(author: user)
  end

  def resolve_department
    scope.where(department: user.department)
  end

  def resolve_creator
    scope.where(creator: user)
  end
end
