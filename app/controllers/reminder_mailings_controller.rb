class ReminderMailingsController < ApplicationController
  before_action :set_reminder_mailing, only: [:show, :edit, :update, :destroy, :send_trial_period,
                                              :send_half_year]

  def index
    authorize ReminderMailing
    @reminder_mailings = ReminderMailing.created_desc
  end

  def show; end

  def new_trial_period
    @assignments = Assignment.need_trial_period_reminder_mailing.distinct
    @group_assignments = GroupAssignment.need_trial_period_reminder_mailing.distinct
    @reminder_mailing = ReminderMailing.new(kind: 'trial_period', creator: current_user,
      reminder_mailing_volunteers: @assignments + @group_assignments)
    @reminder_mailing.assign_attributes(EmailTemplate.trial.active.first.slice(:subject, :body))
    authorize @reminder_mailing
  end

  def new_half_year
    @reminder_mailables = Assignment.submitted_since(params[:submitted_since]&.to_date)
    @reminder_mailables += GroupAssignment.submitted_since(params[:submitted_since]&.to_date)
    @reminder_mailing = ReminderMailing.new(kind: 'half_year',
      reminder_mailing_volunteers: @reminder_mailables)
    @reminder_mailing.assign_attributes(EmailTemplate.half_year.active.first.slice(:subject, :body))
    authorize @reminder_mailing
  end

  def create
    @reminder_mailing = ReminderMailing.new(reminder_mailing_params.merge(creator_id: current_user.id))
    authorize @reminder_mailing
    if @reminder_mailing.save
      redirect_to @reminder_mailing, make_notice
    else
      render "new_#{@reminder_mailing.kind}".to_sym
    end
  end

  def edit
    if @reminder_mailing.sending_triggered
      redirect_back(fallback_location: reminder_mailing_path(@reminder_mailing),
        notice: 'Wenn das Erinnerungs-Mailing bereits versendet wurde, kann es nicht mehr geändert werden.')
    end
  end

  def send_trial_period
    if @reminder_mailing.sending_triggered?
      return redirect_to reminder_mailings_path, notice: 'Dieses Erinnerungs-Mailing wurde bereits versandt.'
    end
    @reminder_mailing.reminder_mailing_volunteers.picked.each do |mailing_volunteer|
      VolunteerMailer.trial_period_reminder(mailing_volunteer).deliver_later
    end
    @reminder_mailing.update(sending_triggered: true)
    redirect_to reminder_mailings_path, notice: 'Probezeit Erinnerungs-Emails werden versendet.'
  end

  def send_half_year
    if @reminder_mailing.sending_triggered?
      return redirect_to reminder_mailings_path, notice: 'Dieses Erinnerungs-Mailing wurde bereits versandt.'
    end
    @reminder_mailing.reminder_mailing_volunteers.picked.each do |mailing_volunteer|
      VolunteerMailer.half_year_reminder(mailing_volunteer).deliver_later
    end
    @reminder_mailing.update(sending_triggered: true)
    redirect_to reminder_mailings_path, notice: 'Halbjahres Erinnerungs-Emails werden versendet.'
  end

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
        :id, :volunteer_id, :reminder_mailable_id, :reminder_mailable_type, :picked
      ])
  end
end
