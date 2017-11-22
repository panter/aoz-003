class VolunteerApplicationsController < ApplicationController
  include AvailabilityAttributes
  include NestedAttributes
  include ContactAttributes
  include VolunteerAttributes

  skip_before_action :authenticate_user!

  def new
    @volunteer = Volunteer.new
    authorize :volunteer_application, :new?
  end

  def create
    @volunteer = Volunteer.new(volunteer_params)
    authorize :volunteer_application, :create?
    if @volunteer.save
      if EmailTemplate.active_mail.signup.present?
        VolunteerMailer.welcome_email(@volunteer, EmailTemplate.active_mail.signup.last).deliver
      end
      redirect_to thanks_volunteer_applications_url
    else
      render :new
    end
  end

  def thanks
    authorize :volunteer_application, :thanks?
  end

  private

  def volunteer_params
    params.require(:volunteer).permit(volunteer_attributes)
  end
end
