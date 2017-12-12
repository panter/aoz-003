class HoursController < ApplicationController
  before_action :set_hour, only: [:show, :edit, :update, :destroy, :create_redirect, :mark_as_done]
  before_action :set_volunteer

  def index
    authorize @volunteer.hours.first || Hour
  end

  def show; end

  def new
    @hour = Hour.new(volunteer: @volunteer)
    authorize @hour
    session[:request_url] = request.referer
  end

  def edit; end

  def create
    @hour = Hour.new(hour_params)
    authorize @hour
    if @hour.save
      redirect_to create_redirect, make_notice
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
    if @hour.update(marked_done_by: current_user)
      redirect_to(
        list_responses_hours_path(q: { marked_done_by_id_null: 'true', s: 'updated_at asc' }),
        notice: 'Stunden als erledigt markiert.'
      )
    else
      redirect_to(
        list_responses_hours_path(q: { marked_done_by_id_null: 'true', s: 'updated_at asc' }),
        notice: 'Fehler: Erledigt markieren fehlgeschlagen.'
      )
    end
  end

  private

  def set_hour
    @hour = Hour.find(params[:id])
    authorize @hour
  end

  def set_volunteer
    @volunteer = Volunteer.find(params[:volunteer_id]) if params[:volunteer_id]
  end

  def create_redirect
    hourable = @hour.hourable
    if !session[:request_url].include?('last_submitted_hours_and_feedbacks')
      @volunteer
    elsif @hour.assignment?
      last_submitted_hours_and_feedbacks_assignment_path(hourable)
    else
      group_assignment = hourable.group_assignments.where(volunteer: @volunteer).last
      last_submitted_hours_and_feedbacks_group_assignment_path(group_assignment)
    end
  end

  def hour_params
    params.require(:hour).permit(:meeting_date, :hours, :minutes, :activity, :comments,
      :volunteer_id, :hourable_id, :hourable_type, :hourable_id_and_type)
  end
end
