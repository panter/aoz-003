class VolunteersController < ApplicationController
  include NestedAttributes
  before_action :set_volunteer, only: [:show, :edit, :update, :destroy]
  before_action :set_state, only: [:update]

  def index
    @q = Volunteer.ransack(params[:q] || { state_cont: 'registered' })
    @volunteers = @q.result
  end

  def show; end

  def new
    @volunteer = Volunteer.new
    @volunteer.schedules << Schedule.build
    authorize @volunteer
  end

  def edit; end

  def create
    @volunteer = Volunteer.new(volunteer_params)
    authorize @volunteer
    if @volunteer.save
      redirect_to @volunteer, notice: t('volunteer_created')
    else
      render :new
    end
  end

  def update
    if @volunteer.update(volunteer_params)
      if @state == Volunteer::INTERESTED && @volunteer.state == Volunteer::ACCEPTED
        new_user = User.new(email: @volunteer.email,
          password: Devise.friendly_token, role: 'volunteer')
        new_user.save
        new_user.invite!
        redirect_to volunteers_path, notice: t('invite_sent', email: new_user.email)
      else
        redirect_to @volunteer, notice: t('volunteer_updated')
      end
    else
      render :edit
    end
  end

  def destroy
    @volunteer.destroy
    redirect_to volunteers_url, notice: t('volunteer_destroyed')
  end

  private

  def set_state
    @state = @volunteer.state
  end

  def set_volunteer
    @volunteer = Volunteer.find(params[:id])
    authorize @volunteer
  end

  def volunteer_params
    params.require(:volunteer).permit(
          volunteer_attributes,
          language_skills_attributes: language_skills_attributes,
          relatives_attributes: relatives_attributes,
          schedules_attributes: schedules_attributes)
  end
end
