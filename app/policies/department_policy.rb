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
    return [user_ids: [], contact_attributes: contact_attrs] if @user.superadmin?
    return [contact_attributes: contact_attrs] if @user.department_manager?
    []
  end

  def phone_attrs
    [:id, :body, :label, :_destroy, :type, :contacts_id]
  end

  def email_attrs
    [:id, :body, :label, :_destroy, :type, :contacts_id]
  end

  def contact_attrs
    [
      :id, :name, :_destroy, :contactable_id, :contactable_type, :street,
      :extended, :city, :postal_code,
      contact_emails_attributes: email_attrs,
      contact_phones_attributes: phone_attrs
    ]
  end

  def index?
    @user.superadmin?
  end

  def show?
    @user.superadmin? || @department.user.include?(@user)
  end

  def new?
    @user.superadmin?
  end

  def edit?
    @user.superadmin? || @department.user.include?(@user)
  end

  def create?
    @user.superadmin?
  end

  def associate_user?
    @user.superadmin?
  end

  def manager_with_department?
    @user.department_manager? && @user.department?
  end

  def update?
    @user.superadmin? || @department.user.include?(@user)
  end

  def destroy?
    @user.superadmin?
  end
end
