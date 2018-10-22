class SemesterProcessVolunteersController < ApplicationController
  before_action :prepare_review, only: [:review_semester, :submit_review]
  before_action :initialize_feedback, only: [:review_semester, :submit_review]

  include SemesterProcessVolunteerHelper

  def review_semester
    @hour = Hour.new
  end

  def submit_review
    assign_reviewed_attributes

    set_reviewed
    begin
      ActiveRecord::Base.transaction do
        @semester_process_volunteer.semester_feedbacks << @feedback
        @hour.save! unless @hour.hours == 0 || @hour.hours.blank?
        @semester_process_volunteer.save!
        @volunteer.save!
      end

      redirect_to(
        review_semester_semester_process_volunteer_path(@semester_process_volunteer),
        notice: 'Successfully reviewed.'
      )
      rescue ActiveRecord::RecordInvalid => exception
        null_reviewed
        @hours.reload
        render :review_semester, notice: exception
    end
  end

  private

  def prepare_review
    # careful cuz mission id can be present in both missions
    @semester_process_volunteer = SemesterProcessVolunteer.find(params[:id])
    @hours = @semester_process_volunteer.hours
    @volunteer = @semester_process_volunteer.volunteer
    @mission = @semester_process_volunteer.missions.first
    authorize @semester_process_volunteer
  end

  def review_params
    params.require(:semester_process_volunteer).permit(
      volunteer_attributes: [:waive, :iban, :bank],
      semester_feedback: [:goals, :achievements, :future, :comments, :conversation],
      hour: [:hours])
  end
end
