class VolunteersController < ApplicationController
  before_action :set_volunteer, only: [:show, :edit, :update, :destroy]

  def index
    @volunteers = Volunteer.all
  end

  def show; end

  def new
    @volunteer = Volunteer.new
  end

  def edit; end

  def create
    @volunteer = Volunteer.new(volunteer_params)

    respond_to do |format|
      if @volunteer.save
        format.html { redirect_to @volunteer, notice: 'Volunteer was successfully created.' }
        format.json { render :show, status: :created, location: @volunteer }
      else
        format.html { render :new }
        format.json { render json: @volunteer.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @volunteer.update(volunteer_params)
        format.html { redirect_to @volunteer, notice: 'Volunteer was successfully updated.' }
        format.json { render :show, status: :ok, location: @volunteer }
      else
        format.html { render :edit }
        format.json { render json: @volunteer.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @volunteer.destroy
    respond_to do |format|
      format.html { redirect_to volunteers_url, notice: 'Volunteer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_volunteer
    @volunteer = Volunteer.find(params[:id])
  end

  def volunteer_params
    params.require(:volunteer).permit(:first_name, :last_name, :date_of_birth,
      :street, :zip, :city, :email, :phone, :nationality, :profession, :education,
      :skills, :motivation, :experience, :strengths, :expectations, :interests,
      :expenses, :state, :man, :woman, :family, :kid, :group_course, :other_support,
      :one_time_support, :short_term_support, :group, :course, :support_city,
      :region, :canton)
  end
end
