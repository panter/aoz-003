class ProfilesController < ApplicationController
  before_action :set_profile, only: %i[show edit update]

  def show; end

  def new
    @profile = Profile.new(user_id: current_user.id)
  end

  def edit; end

  def create
    @profile = Profile.new(profile_params)
    respond_to do |format|
      return format.html { render :new } unless @profile.save
      format.html { redirect_to @profile, notice: 'Profile was successfully created.' }
    end
  end

  def update
    respond_to do |format|
      return format.html { render :edit } unless @profile.update(profile_params)
      format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
    end
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def profile_params
    params.require(:profile).permit(:first_name, :last_name, :phone, :picture,
      :address, :profession, :available_times, :user_id, :monday, :tuesday,
      :wednesday, :thursday, :friday)
  end
end
