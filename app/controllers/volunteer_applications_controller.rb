class VolunteerApplicationsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @volunteer = Volunteer.new
  end

  def create
    @volunteer = Volunteer.new(volunteer_params)
    if @volunteer.save!
      redirect_to action: :thanks
    else
      render :new
    end
  end

  def thanks; end

  private

  def volunteer_params
    params.require(:volunteer).permit(:first_name, :last_name, :date_of_birth, :gender, :avatar,
      :street, :zip, :city, :nationality, :additional_nationality, :email, :phone, :profession,
      :education, :motivation, :experience, :expectations, :strengths, :skills, :interests, :state,
      :duration, :man, :woman, :family, :kid, :sport, :creative, :music, :culture, :training,
      :german_course, :adults, :teenagers, :children, :region)
  end
end
