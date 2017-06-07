class VolunteerApplicationsController < ApplicationController
  include NestedAttributes
  include ContactAttributes

  skip_before_action :authenticate_user!

  def new
    @volunteer = Volunteer.new
    @volunteer.schedules << Schedule.build
    @volunteer.build_contact
  end

  def create
    @volunteer = Volunteer.new(volunteer_params)
    if @volunteer.save
      redirect_to thanks_volunteer_applications_url
    else
      render :new
    end
  end

  def thanks; end

  private

  def volunteer_params
    params.require(:volunteer).permit(
          volunteer_attributes, contact_attributes,
          language_skills_attributes: language_skills_attributes,
          relatives_attributes: relatives_attributes,
          schedules_attributes: schedules_attributes
          )
  end
end
