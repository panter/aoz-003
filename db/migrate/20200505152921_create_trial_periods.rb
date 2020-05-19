class CreateTrialPeriods < ActiveRecord::Migration[5.1]
  def change
    create_table :trial_periods do |t|
      t.date :end_date
      t.datetime :verified_at
      t.references :verified_by, references: :users, index: true
      t.bigint :trial_period_mission_id
      t.string :trial_period_mission_type

      t.datetime :deleted_at, index: true
      t.timestamps
    end

    add_index :trial_periods, %i[trial_period_mission_id trial_period_mission_type], name: 'trial_periods_mission_index'
  end
end
