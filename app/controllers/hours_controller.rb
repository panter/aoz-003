class HoursController < ApplicationController
  before_action :set_hour, only: [:show, :edit, :update, :destroy]
  before_action :set_volunteer

  def index
    authorize @volunteer.hours.first
  end

  def show; end

  def new
    @hour = Hour.new(volunteer: @volunteer)
    authorize @hour
  end

  def edit; end

  def create
    @hour = Hour.new(hour_params)
    authorize @hour
    if @hour.save
      redirect_to @volunteer, make_notice
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

  def set_hour
    @hour = Hour.find(params[:id])
    authorize @hour
  end

  def set_volunteer
    @volunteer = Volunteer.find(params[:volunteer_id]) if params[:volunteer_id]
  end

  def hour_params
    params.require(:hour).permit(:meeting_date, :hours, :minutes, :activity, :comments,
      :volunteer_id, :hourable_id, :hourable_type, :hourable_id_and_type)
  end
end
