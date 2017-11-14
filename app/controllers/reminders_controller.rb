class RemindersController < ApplicationController
  before_action :set_reminder, only: [:update, :destroy]

  def index
    authorize Reminder
    @reminders = Reminder.all
  end

  # Sends the email
  def update
    ReminderMailer.reminder_email(@reminder).deliver
    @reminder.update(sent_at: Time.zone.now)
    redirect_to reminders_url, notice: t('reminder_sent',
      email: @reminder.volunteer.contact.primary_email)
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
end