class VolunteersController < ApplicationController
  include AvailabilityAttributes
  include NestedAttributes
  include ContactAttributes
  include VolunteerAttributes

  before_action :set_volunteer, only: [:show, :edit, :update, :destroy]

  def index
    authorize Volunteer
    @q = policy_scope(Volunteer).ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    respond_to do |format|
      format.xlsx { @volunteers = @q.result }
      format.html { @volunteers = @q.result.paginate(page: params[:page]) }
    end
  end

  def show; end

  def new
    @volunteer = Volunteer.new
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
    @volunteer.attributes = volunteer_params
    return render :edit unless @volunteer.valid?
    if handle_volunteer_update
      redirect_to volunteers_path, notice: t('invite_sent', email: @volunteer.primary_email)
    else
      redirect_to @volunteer, notice: t('volunteer_updated')
    end
  end

  def destroy
    @volunteer.destroy
    redirect_to volunteers_url, notice: t('volunteer_destroyed')
  end

  def seeking_clients
    authorize Volunteer
    @q = policy_scope(Volunteer).seeking_clients.ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @seeking_clients = @q.result.paginate(page: params[:page])
  end

  private

  def handle_volunteer_update
    if @volunteer.acceptance_change == ['undecided', 'accepted'] && @volunteer.user_id.blank?
      @volunteer.save && invite_volunteer_user
    else
      @volunteer.save!
      false
    end
  end

  def invite_volunteer_user
    return false if @volunteer.external
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
    params.require(:volunteer).permit(volunteer_attributes, :bank, :iban, :waive, :acceptance,
      :take_more_assignments, :external)
  end
end
