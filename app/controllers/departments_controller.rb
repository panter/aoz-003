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
    @department = Department.new
    @department.update_attributes(permitted_attributes(@department))
    authorize @department
    if @department.save
      redirect_to @department, notice: t('department_created')
    else
      render :new
    end
  end

  def update
    authorize @department
    if @department.update_attributes(permitted_attributes(@department))
      redirect_to @department, notice: t('department_updated')
    else
      render :edit
    end
  end

  def destroy
    authorize @department
    @department.destroy
    redirect_to departments_url, notice: t('department_destroyed')
  end

  private

  def set_department
    @department = Department.find(params[:id])
  end

  def department_params
    params.require(:department).permit(policy(@department).permitted_attributes)
  end
end
