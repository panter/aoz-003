class EventsController < ApplicationController
  before_action :set_event, except: [:index, :new, :create]

  def index
    authorize Event
    @q = Event.ransack(params[:q])
    @q.sorts = ['date desc'] if @q.sorts.empty?
    @events = @q.result.paginate(page: params[:page])
  end

  def show
    @volunteers = @event.intro_course? ? Volunteer.needs_intro_course : Volunteer.accepted.internal
    @volunteers -= @event.event_volunteers.map(&:volunteer)
    @event_volunteer = EventVolunteer.new(event: @event)
    respond_to do |format|
      format.html
      format.xlsx
    end
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
      :kind, :date, :start_time, :end_time, :title, :description, :department_id, :creator_id, :speaker
    )
  end
end
