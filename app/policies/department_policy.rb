class DepartmentPolicy < ApplicationPolicy
  class Scope < ApplicationScope
    def resolve
      return all if superadmin?
      resolve_owner if department_manager?
    end
  end

  # controller action policies
  alias_method :index?,   :superadmin?
  alias_method :new?,     :superadmin?
  alias_method :create?,  :superadmin?
  alias_method :destroy?, :superadmin?

  def superadmin_or_user_in_records_related?
    superadmin? || record.user_ids.include?(user.id)
  end

  alias_method :show?,   :superadmin_or_user_in_records_related?
  alias_method :edit?,   :superadmin_or_user_in_records_related?
  alias_method :update?, :superadmin_or_user_in_records_related?

  # supplemental policies
  alias_method :can_associate_user?, :superadmin?

  def manager_with_department?
    department_manager? && user.manages_department?
  end

  def permitted_attributes
    return department_attributes.push(user_ids: []) if superadmin?
    return department_attributes if department_manager?
    []
  end

  private

  def department_attributes
    [
      contact_attributes: [
        :id, :last_name, :_destroy, :contactable_id, :contactable_type, :street,
        :extended, :city, :postal_code, :primary_email, :primary_phone
      ]
    ]
  end
end
