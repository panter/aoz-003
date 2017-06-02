class VolunteersController < ApplicationController
  include NestedAttributes
  include VolunteerAttributes
  before_action :set_volunteer, only: [:show, :edit, :update, :destroy]

  def index
    @q = Volunteer.ransack(params[:q])
    @volunteers = @q.result
  end

  def show; end

  def new
    @volunteer = Volunteer.new
    @volunteer.schedules << Schedule.build
    @volunteer.build_contact
    authorize @volunteer
  end

  def edit; end

  def create
    @volunteer = Volunteer.new(volunteer_params)
    authorize @volunteer
    if @volunteer.save
      redirect_to @volunteer, notice: t('volunteer_created')
    else
      render :new
    end
  end

  def update
    state_was_registered = @volunteer.registered?
    return render :edit unless @volunteer.update(volunteer_params)
    return invite_volunteer_user if state_was_registered && @volunteer.accepted?
    redirect_to @volunteer, notice: t('volunteer_updated')
  end

  def destroy
    @volunteer.destroy
    redirect_to volunteers_url, notice: t('volunteer_destroyed')
  end

  private

  def invite_volunteer_user
    new_user = User.new(email: @volunteer.contact.contact_emails.first.body,
      password: Devise.friendly_token, role: 'volunteer')
    new_user.save
    @volunteer.user = new_user
    new_user.invite!
    redirect_to volunteers_path, notice: t('invite_sent', email: new_user.email)
  end

  def set_volunteer
    @volunteer = Volunteer.find(params[:id])
    authorize @volunteer
  end

  def volunteer_params
    params.require(:volunteer).permit(
      volunteer_attributes,
      language_skills_attributes, relatives_attributes, schedules_attributes,
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
