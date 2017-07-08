class VolunteerApplicationsController < ApplicationController
  include NestedAttributes
  include ContactAttributes
  include VolunteerAttributes

  skip_before_action :authenticate_user!

  def new
    @volunteer = Volunteer.new
  end

  def create
    @volunteer = Volunteer.new(volunteer_params)
    if @volunteer.save
      volunteer_email = VolunteerEmail.active_mail
      if volunteer_email.present?
        VolunteerMailer.welcome_email(@volunteer, volunteer_email).deliver
      end
      redirect_to thanks_volunteer_applications_url
    else
      render :new
    end
  end

  def thanks; end

  private

  def volunteer_params
    params.require(:volunteer).permit(volunteer_attributes)
  end
end
