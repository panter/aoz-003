class ProfilesController < ApplicationController
  include AvailabilityAttributes
  include ContactAttributes

  before_action :set_profile, only: [:show, :edit, :update]

  def show; end

  def new
    @profile = Profile.new(user: current_user)
    @profile.contact.primary_email = current_user.email

    authorize @profile
  end

  def edit; end

  def create
    @profile = Profile.new(profile_params)
    authorize @profile
    if @profile.save
      redirect_to @profile, make_notice
    else
      render :new
    end
  end

  def update
    if @profile.update(profile_params)
      redirect_to @profile, make_notice
    else
      render :edit unless @profile.update(profile_params)
    end
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
    authorize @profile
  end

  def profile_params
    params.require(:profile).permit(
      :user_id, :picture, :profession, :avatar,
      contact_attributes, availability_attributes
    )
  end
end
