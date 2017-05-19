class VolunteersController < ApplicationController
  include NestedAttributes
  before_action :set_volunteer, only: [:show, :edit, :update, :destroy]

  def index
    @volunteers = Volunteer.all
  end

  def show; end

  def new
    @volunteer = Volunteer.new
    @volunteer.schedules << Schedule.build
  end

  def edit; end

  def create
    @volunteer = Volunteer.new(volunteer_params)
    if @volunteer.save
      redirect_to @volunteer, notice: t('volunteer_created')
    else
      render :new
    end
  end

  def update
    if @volunteer.update(volunteer_params)
      redirect_to @volunteer, notice: t('volunteer_updated')
    else
      render :edit
    end
  end

  def destroy
    @volunteer.destroy
    redirect_to volunteers_url, notice: t('volunteer_destroyed')
  end

  private

  def set_volunteer
    @volunteer = Volunteer.find(params[:id])
  end

  def volunteer_params
    params.require(:volunteer).permit(:first_name, :last_name, :date_of_birth, :gender, :avatar,
      :street, :zip, :city, :nationality, :additional_nationality, :email, :phone, :profession,
      :education, :motivation, :experience, :expectations, :strengths, :skills, :interests, :state,
      :duration, :man, :woman, :family, :kid, :sport, :creative, :music, :culture, :training,
      :german_course, :adults, :teenagers, :children, :region,
      language_skills_attributes: language_skills_attributes,
      relatives_attributes: relatives_attributes,
      schedules_attributes: schedules_attributes)
  end
end
