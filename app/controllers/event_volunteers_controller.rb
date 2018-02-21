class EventVolunteersController < ApplicationController
  before_action :set_event

  def create
    authorize EventVolunteer
    @event.event_volunteers << EventVolunteer.new(event_volunteer_params.merge(event_id: params[:event_id]))
    if @event.save
      redirect_to @event, make_notice
    else
      render 'events/show'
    end
  end

  def destroy
    event_volunteer = @event.event_volunteers.find(params[:id])
    if event_volunteer.delete && @event.reload
      redirect_to @event, notice: 'Teilnehmende erfolgreich hinzugefügt.'
    else
      redirect_to @event, notice: 'Löschen fehlgeschlagen.'
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
    authorize EventVolunteer
  end

  def event_volunteer_params
    params.require(:event_volunteer).permit(:volunteer_id)
  end
end
