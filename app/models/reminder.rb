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

    existing_reminders = Reminder.all.count

    Volunteer.includes(:assignments).find_each.count do |volunteer|
      volunteer.assignments.each do |assignment|
        conditionally_create_reminder_for_volunteer(volunteer, assignment)
      end
    end

    reminders_created_count = Reminder.all.count - existing_reminders

    logger.info("Created #{reminders_created_count} reminders, reference Date #{time}")
    logger.flush

    reminders_created_count
  end

  def self.conditionally_create_reminder_for_volunteer(volunteer, assignment)
    log_message =
      if assignment.period_start? && assignment.period_start > 6.months.ago
        'not yet 6 months'
      elsif assignment.confirmation?
        'already confirmed'
      elsif assignment.inactive?
        'not active assignment'
      elsif assignment.reminders.any?
        'reminder already present'
      else
        reminder = Reminder.create_for(volunteer, assignment)
        "created reminder [#{reminder.id}]"
      end
    logger.info("[#{volunteer.id}] #{volunteer.contact.full_name}:" + log_message)
    logger.flush
  end
end
