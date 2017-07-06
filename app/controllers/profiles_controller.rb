class ProfilesController < ApplicationController
  include ContactAttributes
  include MakeNotice

  before_action :set_profile, only: [:show, :edit, :update]

  def show; end

  def new
    @profile = Profile.new(user_id: current_user.id)
    @profile.build_contact
    authorize @profile
  end

  def edit; end

  def create
    @profile = Profile.new(profile_params)
    if @profile.save
      redirect_to @profile, make_notice
    else
      render :new
    end
    authorize @profile
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
      :user_id, :picture, :profession, :monday,
      :tuesday, :wednesday, :thursday, :friday, :avatar,
      contact_attributes
      )
  end
end
