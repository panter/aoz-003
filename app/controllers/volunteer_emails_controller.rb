class VolunteerEmailsController < ApplicationController
  before_action :set_volunteer_email, only: [:show, :edit, :update, :destroy]
  before_action :translate_model_name, only: [:update, :destroy]

  def index
    authorize VolunteerEmail
    @volunteer_emails = VolunteerEmail.all.order(created_at: :desc)
  end

  def show; end

  def new
    @volunteer_email = VolunteerEmail.new
    authorize @volunteer_email
  end

  def edit; end

  def create
    @volunteer_email = VolunteerEmail.new(volunteer_email_params)
    @volunteer_email.user = current_user
    authorize @volunteer_email
    if @volunteer_email.save
      redirect_to @volunteer_email,
        notice: t('crud.created', model: @volunteer_email.class.model_name.human)
    else
      render :new
    end
  end

  def update
    if @volunteer_email.update(volunteer_email_params)
      redirect_to @volunteer_email, notice: t('crud.updated', model: @translated_model_name)
    else
      render :edit
    end
  end

  def destroy
    @volunteer_email.destroy
    redirect_to volunteer_emails_url, notice: t('crud.destroyed', model: @translated_model_name)
  end

  private

  def set_volunteer_email
    @volunteer_email = VolunteerEmail.find(params[:id])
    authorize @volunteer_email
  end

  def translate_model_name
    @translated_model_name = @volunteer_email.class.model_name.human
  end

  def volunteer_email_params
    params.require(:volunteer_email).permit(:subject, :title, :body, :user_id, :active)
  end
end
