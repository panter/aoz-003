class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update]

  def show
    authorize @profile
  end

  def new
    @profile = Profile.new(user_id: current_user.id)
    authorize @profile
  end

  def edit
    authorize @profile
  end

  def create
    @profile = Profile.new(profile_params)
    if @profile.save
      redirect_to @profile, notice: t('profile_created')
    else
      render :new
    end
    authorize @profile
  end

  def update
    if @profile.update(profile_params)
      redirect_to @profile, notice: t('profile_updated')
    else
      render :edit unless @profile.update(profile_params)
    end
    authorize @profile
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def profile_params
    params.require(:profile).permit(
      :user_id, :first_name, :last_name, :phone, :picture, :address, :profession, :monday,
      :tuesday, :wednesday, :thursday, :friday, :avatar
    )
  end
end
