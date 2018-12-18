module ReminderMailingBuilder
  def create_mailing(kind, body, subject, creator, *mailables)
    mailing = ReminderMailing.new(
      creator: creator, kind: kind, body: body, subject: subject,
      reminder_mailing_volunteers: mailing_volunteers(mailables))
    mailing.reminder_mailing_volunteers.map { |rmv| rmv.picked = true }
    mailing.save
    mailing
  end

  def create_probation_mailing(*mailables)
    create_mailing('trial_period', 'aaa', 'aaa', create(:user), *mailables)
  end

  def create_termination_mailing(*mailables)
    create_mailing('termination', 'aaa', 'aaa', create(:user), *mailables)
  end

  def mailing_volunteers(mailables)
    mailables.each do |mailable|
      ReminderMailingVolunteer.new(volunteer: mailable.volunteer,
        reminder_mailable: mailable)
    end
  end
end
