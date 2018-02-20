class EventVolunteersController < ApplicationController
  before_action :set_event

  def create
    authorize EventVolunteer
    @event_volunteer = EventVolunteer.new(event_volunteer_params.merge(event_id: params[:event_id]))
    if @event_volunteer.save
      redirect_to @event, make_notice
    else
      render 'events/show'
    end
  end

  def update; end

  def destroy
    if @event.event_volunteers.where()
      redirect_to @event, make_notice
    else
      redirect_to @event, notice: 'Löschen fehlgeschlagen.'
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def event_volunteer_params
    params.require(:event_volunteer).permit(:volunteer_id)
  end
end
