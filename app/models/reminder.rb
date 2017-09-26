class Reminder < ApplicationRecord
  belongs_to :assignment
  belongs_to :volunteer

  default_scope { order(created_at: :desc) }

  def self.create_for(volunteer, assignment)
    Reminder.create!(volunteer: volunteer, assignment: assignment)
  end

  def self.conditionally_create_reminders(time = Time.zone.now)
    logger.info("Beginning reminder run, reference Date #{time}")
    logger.flush
    reminders_created = Volunteer.with_assignment_6_months_ago.map do |volunteer|
      volunteer.assignments.map do |assignment|
        conditionally_create_reminder_for_volunteer(volunteer, assignment)
      end
    end.flatten.compact
    logger.info("Created #{reminders_created.count} reminders, reference Date #{time}")
    logger.flush

    reminders_created.size
  end

  def self.conditionally_create_reminder_for_volunteer(volunteer, assignment)
    if !assignment.started_six_months_ago?
      log_reminder volunteer, 'not yet 6 months'
      nil
    elsif assignment.confirmation?
      log_reminder volunteer, 'already confirmed'
      nil
    elsif assignment.inactive?
      log_reminder volunteer, 'not active assignment'
      nil
    elsif assignment.reminders.any?
      log_reminder volunteer, 'reminder already present'
      nil
    else
      reminder = Reminder.create_for(volunteer, assignment)
      log_reminder volunteer, "created reminder [#{reminder.id}]"
      reminder.id
    end
  end

  def self.log_reminder(volunteer, message)
    logger.info("[#{volunteer.id}] #{volunteer.contact.full_name}: #{message}")
    logger.flush
  end
end
