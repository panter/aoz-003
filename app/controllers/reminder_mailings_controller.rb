class ReminderMailingsController < ApplicationController
  before_action :set_reminder_mailing, only: [:show, :edit, :update, :destroy]

  def index
    authorize ReminderMailing
    @reminder_mailings = ReminderMailing.all
  end

  def show; end

  def new_probation_period
    @assignments = Assignment.need_probation_period_reminder_mailing.distinct
    @reminder_mailing = ReminderMailing.new(
      kind: 'probation_period', reminder_mailing_volunteers: @assignments
    )
    authorize @reminder_mailing
  end

  def new_half_year
    @reminder_mailables = Assignment.started_six_months_ago + GroupAssignment.started_six_months_ago
    @reminder_mailing = ReminderMailing.new(
      kind: 'half_year', reminder_mailing_volunteers: @reminder_mailables
    )
    authorize @reminder_mailing
  end

  def create
    @reminder_mailing = ReminderMailing.new(reminder_mailing_params)
    @reminder_mailing.creator = current_user
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
    params.require(:reminder_mailing).permit(:body, :kind, :subject, :volunteers,
      reminder_mailing_volunteers_attributes: [
        :volunteer_id, :reminder_mailable_id, :reminder_mailable_type, :selected
      ])
  end
end
