class AddTrialPeriodToVolunteers < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteers, :trial_period, :boolean, default: false
  end
end
