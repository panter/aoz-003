class ProfilesController < ApplicationController
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
      contact_attributes: [
        :id, :first_name, :last_name, :_destroy, :contactable_id, :contactable_type, :street,
        :extended, :city, :postal_code,
        contact_emails_attributes: contact_point_attrs,
        contact_phones_attributes: contact_point_attrs]
      )
  end

  def contact_point_attrs
    [:id, :body, :label, :_destroy, :type, :contacts_id]
  end
end
