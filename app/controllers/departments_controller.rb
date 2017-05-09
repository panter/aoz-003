class DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :edit, :update, :destroy]

  def index
    @departments = Department.all
  end

  def show; end

  def new
    @department = Department.new
  end

  def edit; end

  def create
    @department = Department.new(department_params)
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
    @department.destroy
    respond_to do |format|
      format.html do
        redirect_to departments_url, notice:  t('department_destroyed')
      end
    end
  end

  private

  def set_department
    @department = Department.find(params[:id])
  end

  def department_params
    params.require(:department).permit(:name)
  end
end
