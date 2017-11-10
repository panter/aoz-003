class Reminder < ApplicationRecord
  belongs_to :assignment
  belongs_to :volunteer

  enum kind: { trial: 0, assignment: 1 }

  validate :volunteer_is_internal?

  def volunteer_is_internal?
    errors.add(:volunteer, 'external volunteers can not get reminders') if volunteer.external
  end

  default_scope { order(created_at: :desc) }

  def self.create_for(volunteer, assignment)
    Reminder.create!(volunteer: volunteer, assignment: assignment, kind: 1)
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

  def self.trial_end_reminders
    Volunteer.with_assignment_ca_6_weeks_ago.map do |volunteer|
      volunteer.assignments.map do |assignment|
        conditionally_create_trial_end_reminder_for_volunteer(volunteer, assignment)
      end
    end.flatten.compact
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

  def self.conditionally_create_trial_end_reminder_for_volunteer(volunteer, a)
    Reminder.create!(volunteer: volunteer, assignment: a, kind: 0) if a.started_ca_six_weeks_ago? &&
        !a.confirmation? && a.reminders.none? && a.feedbacks.trial.none?
  end

  def self.log_reminder(volunteer, message)
    logger.info("[#{volunteer.id}] #{volunteer.contact.full_name}: #{message}")
    logger.flush
  end
end
