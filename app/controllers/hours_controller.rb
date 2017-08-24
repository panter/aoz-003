class HoursController < ApplicationController
  include MakeNotice
  before_action :set_hour, only: [:show, :edit, :update, :destroy]

  def index
    authorize Hour
    @hours = Hour.all
  end

  def show; end

  def new
    @hour = Hour.new(volunteer_id: params[:volunteer_id])
    @clients = Client.having_volunteer
    @assignments = Assignment.where(volunteer: params[:volunteer_id])
    @assignments_clients = if params[:volunteer_id]
                             @assignments.map do |assignment|
                               [assignment.client.to_s, assignment.id]
                             end
                           else
                             @assignments_clients = @clients.map do |client|
                               [client.to_s, client.assignment.id]
                             end
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
    if current_user.superadmin?
      redirect_to hours_url, make_notice
    else
      redirect_to volunteer_hours_volunteer_path(@hour.volunteer), make_notice
    end
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
