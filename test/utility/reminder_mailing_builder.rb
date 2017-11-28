module ReminderMailingBuilder
  def create_mailing(*mailables)
    mailing = ReminderMailing.new(
      creator: create(:user), kind: 'probation_period', body: 'bogus', subject: 'bogus',
      reminder_mailing_volunteers: mailing_volunteers(mailables))
    mailing.reminder_mailing_volunteers.map { |rmv| rmv.selected = '1' }
    mailing.save
    mailing
  end

  def mailing_volunteers(mailables)
    mailables.each do |mailable|
      ReminderMailingVolunteer.new(volunteer: mailable.volunteer,
        reminder_mailable: mailable)
    end
  end
end
