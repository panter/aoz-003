class CoplanersController < ApplicationController
  # rubocop:disable Metrics/AbcSize
  def index
    authorize :coplaner
    @volunteers = Volunteer.all.order(:id)
    @clients = Client.all.order(:id)
    @assignments = Assignment.all.order(:id)
    @group_offers = GroupOffer.all.order(:id)
    @group_assignments = GroupAssignment.all.order(:id)
    @hours = Hour.all.order(:id)
    @events = Event.all.order(:id)
    @event_volunteers = EventVolunteer.all.order(:id)
    @billing_expenses = BillingExpense.all.order(:id)
    @departments = Department.all.order(:id)
  end
  # rubocop:enable Metrics/AbcSize
end
