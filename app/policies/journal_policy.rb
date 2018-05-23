class JournalPolicy < ApplicationPolicy
  def superadmin_or_department_manager?
    superadmin? || department_manager?
  end

  alias_method :new?,     :superadmin_or_department_manager?
  alias_method :create?,  :superadmin_or_department_manager?
  alias_method :index?,   :superadmin_or_department_manager?
  alias_method :edit?,    :superadmin_or_department_manager?
  alias_method :update?,  :superadmin_or_department_manager?
  alias_method :destroy?, :superadmin_or_department_manager?
end
