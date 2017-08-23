class HoursController < ApplicationController
  include MakeNotice
  before_action :set_hour, only: [:show, :edit, :update, :destroy]

  def index
    authorize Hour
    @hours = policy_scope(Hour)
  end

  def show; end

  def new
    @hour = Hour.new(volunteer_id: params[:volunteer_id])
    @assignments = Assignment.where(volunteer: params[:volunteer_id])
    @assignments_clients = @assignments.map do |assignment|
      [assignment.client.to_s, assignment.id]
    end
    authorize @hour
  end

  def edit; end

  def create
    @hour = Hour.new(hour_params)
    authorize @hour
    if @hour.save
      redirect_to @hour, make_notice
    else
      render :new
    end
  end

  def update
    if @hour.update(hour_params)
      redirect_to @hour, make_notice
    else
      render :edit
    end
  end

  def destroy
    @hour.destroy
    redirect_to hours_url, make_notice
  end

  private

  def set_hour
    @hour = Hour.find(params[:id])
    authorize @hour
  end

  def hour_params
    params.require(:hour).permit(:meeting_date, :duration, :activity, :comments, :volunteer_id,
      :assignment_id)
  end
end
