class AddTrialPeriodReferenceToAssignments < ActiveRecord::Migration[5.1]
  def up
    missions = Assignment.where.not(trial_period_end: [nil, '']).where('created_at >= ?', 3.months.ago) +
               GroupAssignment.where.not(trial_period_end: [nil, '']).where('created_at >= ?', 3.months.ago)
    missions.each do |mission|
      parsed_date =  convert_string_date(mission.trial_period_end)
      next unless parsed_date

      mission.trial_period.end_date = parsed_date
      mission.save!
    end
  end

  def convert_string_date(date)
    Date.parse(date)
  rescue ArgumentError
    return nil
  end

  def down
    TrialPeriod.where.not(end_date: nil).find_each do |trial_period|
      trial_period.mission.update(trial_period_end: l(trial_piriod.end_date))
    end
  end
end
