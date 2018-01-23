class NotificationMailer < ApplicationMailer
  def termination_submitted assignment
    @assignment = assignment
    @subject = "Beendigung des Einsatzes bestätigt durch #{assignment.termination_submitted_by.email}"

    mail(to: assignment.creator.email, subject: @subject)
  end
end
