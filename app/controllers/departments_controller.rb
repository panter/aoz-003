class DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :edit, :update, :destroy]

  def index
    @departments = policy_scope(Department)
  end

  def show
    authorize @department
  end

  def new
    @department = Department.new
    @department.build_contact
    authorize @department
  end

  def edit
    authorize @department
  end

  def create
    @department = Department.new(department_params)
    authorize @department
    respond_to do |format|
      if @department.save
        format.html do
          redirect_to @department, notice: t('department_created')
        end
      else
        format.html { render :new }
      end
    end
  end

  def update
    authorize @department
    respond_to do |format|
      if @department.update(department_params)
        format.html do
          redirect_to @department, notice: t('department_updated')
        end
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    authorize @department
    @department.destroy
    respond_to do |format|
      format.html do
        redirect_to departments_url, notice: t('department_destroyed')
      end
    end
  end

  private

  def set_department
    @department = Department.find(params[:id])
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

  def department_params
    params.require(:department).permit(user_ids: [], contact_attributes: contact_attrs)
  end
end
