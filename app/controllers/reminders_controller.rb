class RemindersController < ApplicationController
  before_action :set_reminder, only: [:update, :destroy]

  def index
    authorize Reminder
    @reminders = Reminder.all
  end

  # Sends the email
  def update
    volunteer = @reminder.volunteer
    email = @reminder.volunteer.contact.primary_email
    ReminderMailer.reminder_email(volunteer, @reminder, email).deliver
    @reminder.update(sent_at: Time.zone.now)
    redirect_to reminders_url, notice: t('reminder_sent', email: email)
  end

  def destroy
    @reminder.destroy
    redirect_to reminders_url, make_notice
  end

  private

  def set_reminder
    @reminder = Reminder.find(params[:id])
    authorize @reminder
  end

  def reminder_params
    {}
  end
end
