class ReminderMailingsController < ApplicationController
  before_action :set_reminder_mailing, only: [:show, :edit, :update, :destroy, :send_termination]

  def index
    authorize ReminderMailing
    @q = ReminderMailing
      .includes(creator: { profile: :contact }, reminder_mailing_volunteers: :reminder_mailable)
      .ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    @reminder_mailings = @q.result
  end

  def show; end

  def new_termination
    @reminder_mailing = ReminderMailing.new(kind: 'termination',
      reminder_mailing_volunteers: [find_termination_mailable])
    if EmailTemplate.termination.active.any?
      @reminder_mailing.assign_attributes(EmailTemplate.termination.active.first
        .slice(:subject, :body))
    else
      redirect_to new_email_template_path,
                  notice: 'Sie müssen eine aktive E-Mailvorlage haben,
        bevor Sie eine Abschlussevaluations E-Mail erstellen können.'
    end
    authorize @reminder_mailing
  end

  def create
    @reminder_mailing = ReminderMailing.new(
      reminder_mailing_params.merge(creator_id: current_user.id)
    )
    authorize @reminder_mailing
    if @reminder_mailing.save
      redirect_to @reminder_mailing, make_notice
    else
      render "new_#{@reminder_mailing.kind}".to_sym
    end
  end

  def edit
    return unless @reminder_mailing.sending_triggered

    redirect_back(fallback_location: reminder_mailing_path(@reminder_mailing), notice: 'Wenn das'\
      ' Erinnerungs-Mailing bereits versendet wurde, kann es nicht mehr geändert werden.')
  end

  def send_termination
    if @reminder_mailing.sending_triggered?
      return redirect_to reminder_mailings_path, notice: 'Dieses Beendigungs-Mailing wurde bereits'\
        ' versandt.'
    end
    VolunteerMailer.public_send(@reminder_mailing.kind,
                                @reminder_mailing.reminder_mailing_volunteers.first).deliver_later
    @reminder_mailing.update(sending_triggered: true)
    redirect_to reminder_mailings_path, notice: 'Beendigungs-Email wird versendet.'
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

  def find_termination_mailable
    Assignment.find_by(id: params[:assignment_id]) ||
      GroupAssignment.find_by(id: params[:group_assignment_id])
  end

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
