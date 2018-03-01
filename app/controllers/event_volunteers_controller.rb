class EventVolunteersController < ApplicationController
  before_action :set_event

  def create
    authorize EventVolunteer
    @event.event_volunteers << EventVolunteer.new(
      event_volunteer_params.merge(event_id: params[:event_id], creator_id: current_user.id)
    )
    if @event.save
      redirect_to @event, notice: 'Teilnehmer/in erfolgreich hinzugefügt.'
    elsif volunteer_is_not_twice_in_same_event
      redirect_to @event, notice: 'Freiwillige/r wurde bereits zu dieser Veranstaltung hinzugefügt.'
    elsif
      render 'events/show'
    end
  end

  def destroy
    @event_volunteer = @event.event_volunteers.find(params[:id])
    if @event_volunteer.destroy
      redirect_to @event, notice: 'Teilnehmer/in erfolgreich gelöscht.'
    else
      redirect_to @event, notice: 'Löschen fehlgeschlagen.'
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
    authorize EventVolunteer
  end

  def volunteer_is_not_twice_in_same_event
    !(@event.volunteers.include? @volunteer)
  end

  def event_volunteer_params
    params.require(:event_volunteer).permit(:volunteer_id, :creator_id)
  end
end
