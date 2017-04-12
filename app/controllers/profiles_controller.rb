class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update]

  def show; end

  def new
    @profile = Profile.new(user_id: current_user.id)
  end

  def edit; end

  def create
    @profile = Profile.new(profile_params)
    respond_to do |format|
      if @profile.save
        format.html { redirect_to @profile, notice: 'Profile was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
      else
        format.html { render :edit } unless @profile.update(profile_params)
      end
    end
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def profile_params
    params.require(:profile).permit(
      :user_id, :first_name, :last_name, :phone, :picture, :address, :profession, :monday,
      :tuesday, :wednesday, :thursday, :friday
    )
  end
end
