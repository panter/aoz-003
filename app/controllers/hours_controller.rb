class HoursController < ApplicationController
  include MakeNotice

  before_action :set_hour, only: [:show, :edit, :update, :destroy]
  before_action :set_houred

  def index
    hour = Hour.new(volunteer: @houred)
    authorize hour
    @hours =  Hour.where(volunteer: @houred)
  end

  def show; end

  def new
    @hour = Hour.new(volunteer: @houred)
    @assignments_clients = select_clients
    authorize @hour
  end

  def edit; end

  def create
    @hour = Hour.new(hour_params)
    authorize @hour
    if @hour.save
      redirect_to @houred, make_notice
    else
      render :new
    end
  end

  def update
    if @hour.update(hour_params)
      redirect_to @houred, make_notice
    else
      render :edit
    end
  end

  def destroy
    @hour.destroy
    redirect_to @houred, make_notice
  end

  private

  def select_clients
    assignments = Assignment.where(volunteer: params[:volunteer_id])
    assignments.map do |assignment|
      [assignment.client.to_s, assignment.id]
    end
  end

  def set_hour
    @hour = Hour.find(params[:id])
    authorize @hour
  end

  def set_houred
    @houred = Volunteer.find(params[:volunteer_id]) if params[:volunteer_id]
  end

  def hour_params
    params.require(:hour).permit(:meeting_date, :hours, :minutes, :activity, :comments,
      :volunteer_id, :assignment_id)
  end
end
