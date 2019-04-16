class NotificationMailer < ApplicationMailer
  def termination_submitted(terminated)
    @terminated = terminated
    @link_params = { q: { termination_verified_by_id_not_null: 'true' } }
    mail(
      to: terminated.period_end_set_by&.email || terminated.creator.email,
      subject: I18n.t(
        'notification_mailer.termination_submitted.subject',
        email: @terminated.termination_submitted_by.email
      )
    )
  end
end
