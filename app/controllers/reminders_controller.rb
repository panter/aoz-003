class RemindersController < ApplicationController
  before_action :set_reminder, only: [:update, :destroy]

  def index
    authorize Reminder
    @reminders = Reminder.all
  end

  def update
    redirect_to reminders_url, notice: 'Reminder was successfully updated.'
  end

  def destroy
    @reminder.destroy
    redirect_to reminders_url, notice: 'Reminder was successfully destroyed.'
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
