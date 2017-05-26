class DepartmentPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :department
    def initialize(user, department)
      @user = user
      @department = department
    end

    def resolve
      if @user.superadmin?
        @department.all
      else
        @department.where(user: @user)
      end
    end
  end

  def initialize(user, department)
    @user = user
    @department = department
  end

  def permitted_attributes
    return department_attributes.push(user_ids: []) if @user.superadmin?
    return department_attributes if @user.department_manager?
    []
  end

  def index?
    @user.superadmin?
  end

  def show?
    superadmin_or_users_department?
  end

  def new?
    @user.superadmin?
  end

  def edit?
    superadmin_or_users_department?
  end

  def create?
    @user.superadmin?
  end

  def can_associate_user?
    @user.superadmin?
  end

  def manager_with_department?
    @user.department_manager? && @user.with_department?
  end

  def update?
    superadmin_or_users_department?
  end

  def destroy?
    @user.superadmin?
  end

  private

  def superadmin_or_users_department?
    @user.superadmin? || @department.user.include?(@user)
  end

  def contact_point_attrs
    [:id, :body, :label, :_destroy, :type, :contacts_id]
  end

  def department_attributes
    [
      contact_attributes: [
        :id, :name, :_destroy, :contactable_id, :contactable_type, :street,
        :extended, :city, :postal_code,
        contact_emails_attributes: contact_point_attrs,
        contact_phones_attributes: contact_point_attrs
      ]
    ]
  end
end
