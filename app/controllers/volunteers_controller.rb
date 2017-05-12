class VolunteersController < ApplicationController
  before_action :set_volunteer, only: [:show, :edit, :update, :destroy]

  def index
    @volunteers = Volunteer.all
  end

  def show; end

  def new
    @volunteer = Volunteer.new
  end

  def edit; end

  def create
    @volunteer = Volunteer.new(volunteer_params)
    respond_to do |format|
      if @volunteer.save
        format.html { redirect_to @volunteer, notice: t('volunteer_created') }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @volunteer.update(volunteer_params)
        format.html { redirect_to @volunteer, notice: t('volunteer_updated') }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @volunteer.destroy
    respond_to do |format|
      format.html { redirect_to volunteers_url, t('volunteer_destroyed', email: @volunteer.email) }
    end
  end

  private

  def set_volunteer
    @volunteer = Volunteer.find(params[:id])
  end

  def volunteer_params
    params.require(:volunteer).permit(:first_name, :last_name, :date_of_birth, :gender,
      :street, :zip, :city, :nationality, :additional_nationality, :email, :phone, :profession,
      :education, :motivation, :experience, :expectations, :strengths, :skills, :interests, :state,
      :duration, :man, :woman, :family, :kid, :sport, :creative, :music, :culture, :training,
      :german_course, :adults, :teenagers, :children, :region)
  end
end
