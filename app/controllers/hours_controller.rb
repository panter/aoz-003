class HoursController < ApplicationController
  before_action :set_hour, only: [:show, :edit, :update, :destroy]
  before_action :set_volunteer

  def index
    authorize @volunteer.hours.first || Hour
    @q = @volunteer.hours.ransack(params[:q])
    @q.sorts = ['meeting_date desc'] if @q.sorts.empty?
    @hours = @q.result
  end

  def show; end

  def new
    @hour = Hour.new(volunteer: @volunteer, hourable: find_hourable)
    authorize @hour
    simple_form_params
  end

  def edit
    simple_form_params
  end

  def create
    @hour = Hour.new(hour_params)
    @hour.hourable ||= find_hourable
    authorize @hour
    simple_form_params
    if @hour.save
      redirect_to default_redirect || @volunteer, notice: t('hours_created')
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

  private

  def simple_form_params
    @simple_form_for_params = [
      [@volunteer, @hour.hourable, @hour], {
        url: polymorphic_path(
          [@volunteer, @hour.hourable, @hour],
          redirect_to: default_redirect, group_assignment: params[:group_assignment]
        )
      }
    ]
  end

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
    @volunteer = Volunteer.find(params[:volunteer_id])
    authorize @volunteer
  end

  def hour_params
    params.require(:hour).permit(:meeting_date, :hours, :activity, :comments,
      :volunteer_id, :hourable_id, :hourable_type, :hourable_id_and_type)
  end
end
