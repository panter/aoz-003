class VolunteersController < ApplicationController
  include NestedAttributes
  include ContactAttributes
  include VolunteerAttributes
  include MakeNotice

  before_action :set_volunteer, only: [:show, :edit, :update, :destroy]

  def index
    @q = Volunteer.ransack(params[:q])
    @volunteers = @q.result
  end

  def show; end

  def new
    @volunteer = Volunteer.new
    @volunteer.build_schedules
    authorize @volunteer
  end

  def edit; end

  def create
    @volunteer = Volunteer.new(volunteer_params)
    @volunteer.registrar = current_user
    authorize @volunteer
    if @volunteer.save
      redirect_to @volunteer, notice: t('volunteer_created')
    else
      render :new
    end
  end

  def update
    state_was_registered = @volunteer.registered?
    return render :edit unless @volunteer.update(volunteer_params)
    if state_was_registered && @volunteer.accepted? && invite_volunteer_user
      redirect_to volunteers_path,
        notice: t('invite_sent', email: @volunteer.contact.primary_email)
    else
      redirect_to @volunteer, notice: t('volunteer_updated')
    end
  end

  def destroy
    @volunteer.destroy
    redirect_to volunteers_url, notice: t('volunteer_destroyed')
  end

  def seeking_clients
    @q = Volunteer.where(state: Volunteer::SEEKING_CLIENTS).ransack(params[:q])
    @seeking_clients = @q.result
  end

  private

  def invite_volunteer_user
    new_user = User.new(
      email: @volunteer.contact.primary_email, password: Devise.friendly_token,
      role: 'volunteer', volunteer: @volunteer
    )
    new_user.save && new_user.invite!
  end

  def set_volunteer
    @volunteer = Volunteer.find(params[:id])
    authorize @volunteer
  end

  def volunteer_params
    params.require(:volunteer).permit(volunteer_attributes, :rejection_type, :rejection_text,
      :trial_period, :intro_course, :doc_sent, :bank_account, :evaluation)
  end
end
