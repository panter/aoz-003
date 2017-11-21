class ReminderMailingsController < ApplicationController
  before_action :set_reminder_mailing, only: [:show, :edit, :update, :destroy]

  def index
    authorize ReminderMailing
    @reminder_mailings = ReminderMailing.all
  end

  def new
    @reminder_mailing = ReminderMailing.new
    authorize @reminder_mailing
  end

  def create
    @reminder_mailing = ReminderMailing.new(reminder_mailing_params)
    authorize @reminder_mailing
    if @reminder_mailing.save
      redirect_to @reminder_mailing, make_notice
    else
      render :new
    end
  end

  def edit;end

  def update
    if @reminder_mailing.update(reminder_mailing_params)
      redirect_to @reminder_mailing, make_notice
    else
      render :edit
    end
  end

  def destroy
    @reminder_mailing.destroy
    redirect_to reminder_mailings_url, make_notice
  end

  private

  def set_reminder_mailing
    @reminder_mailing = ReminderMailing.find(params[:id])
    authorize @reminder_mailing
  end

  def reminder_mailing_params
    params.require(:reminder_mailing).permit(:body, :subject, :volunteers, :kind)
  end
end
