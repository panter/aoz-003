class RemindersController < ApplicationController
  before_action :set_reminder, only: [:update, :destroy]

  def index
    authorize Reminder
    @reminders = Reminder.assignment
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
    @reminder.volunteer.update(trial_period: true) if @reminder.trial?
    redirect_to @reminder.trial? ? trial_end_reminders_url : reminders_url, make_notice
  end

  def trial_end
    authorize Reminder
    Reminder.trial_end_reminders
    @trial_end = Reminder.trial
  end

  private

  def set_reminder
    @reminder = Reminder.find(params[:id])
    authorize @reminder
  end
end
