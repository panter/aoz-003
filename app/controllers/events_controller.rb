class EventsController < ApplicationController
  before_action :set_event, except: [:index, :new, :create]

  def index
    authorize Event
    @events = Event.all
  end

  def show
    @volunteers = Volunteer.needs_intro_course
    @event_volunteer = EventVolunteer.new(event: @event)
  end

  def new
    @event = Event.new
    authorize @event
  end

  def edit; end

  def create
    @event = Event.new(event_params.merge(creator_id: current_user.id))
    authorize @event
    if @event.save
      redirect_to @event, make_notice
    else
      render :new
    end
  end

  def update
    @event.update(event_params)
    if @event.update(event_params)
      redirect_to @event, make_notice
    else
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to events_url, make_notice
  end

  private

  def set_event
    @event = Event.find(params[:id])
    authorize @event
  end

  def event_params
    params.require(:event).permit(
      :kind, :date, :start_time, :end_time, :title, :description, :department_id, :creator_id,
      event_volunteers_attributes: [:id, :volunteer_id, :creator_id]
    )
  end
end
