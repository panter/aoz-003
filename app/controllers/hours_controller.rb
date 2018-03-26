class HoursController < ApplicationController
  before_action :set_hour, only: [:show, :edit, :update, :destroy, :create_redirect, :mark_as_done]
  before_action :set_volunteer

  def index
    authorize @volunteer.hours.first || Hour
  end

  def show; end

  def new
    @hour = Hour.new(volunteer: @volunteer, hourable: find_hourable)
    authorize @hour
    @simple_form_for_params = [
      [@volunteer, @hour.hourable, @hour],
      { url: polymorphic_path([@volunteer, @hour.hourable, @hour],
        redirect_to: params[:redirect_to], group_assignment: params[:group_assignment]) }
    ]
  end

  def edit; end

  def create
    @hour = Hour.new(hour_params)
    @hour.hourable ||= find_hourable
    authorize @hour
    if @hour.save
      redirect_to create_redirect, notice: t('hours_created')
    else
      render :new
    end
  end

  def update
    if @hour.update(hour_params)
      redirect_to @volunteer, make_notice
    else
      render :edit
    end
  end

  def destroy
    @hour.destroy
    redirect_to @volunteer, make_notice
  end

  def mark_as_done
    redirect_path = list_responses_hours_path(params.to_unsafe_hash.slice(:q))
    if @hour.update(reviewer: current_user)
      redirect_to(redirect_path, notice: 'Stunden als angeschaut markiert.')
    else
      redirect_to(redirect_path, notice: 'Fehler: Angeschaut markieren fehlgeschlagen.')
    end
  end

  private

  def find_hourable
    Assignment.find_by(id: params[:assignment_id]) ||
      GroupOffer.find_by(id: params[:group_offer_id])
  end

  def find_hourable_submit_form
    GroupAssignment.find_by(id: params[:group_assignment]) || find_hourable
  end

  def set_hour
    @hour = Hour.find(params[:id])
    authorize @hour
  end

  def set_volunteer
    @volunteer = Volunteer.find(params[:volunteer_id]) if params[:volunteer_id]
  end

  def create_redirect
    return @volunteer unless params[:redirect_to]
    polymorphic_path(find_hourable_submit_form, action: params[:redirect_to]&.to_sym)
  end

  def hour_params
    params.require(:hour).permit(:meeting_date, :hours, :activity, :comments,
      :volunteer_id, :hourable_id, :hourable_type, :hourable_id_and_type)
  end
end
