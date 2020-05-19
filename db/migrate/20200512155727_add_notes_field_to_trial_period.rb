class AddNotesFieldToTrialPeriod < ActiveRecord::Migration[5.1]
  def change
    add_column :trial_periods, :notes, :text
  end
end
