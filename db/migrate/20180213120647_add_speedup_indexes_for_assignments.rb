class AddSpeedupIndexesForAssignments < ActiveRecord::Migration[5.1]
  def change
    change_table :assignments do |t|
      t.index :period_start
      t.index :period_end
      t.index :submitted_at
      t.index :termination_submitted_at
      t.index :termination_verified_at
    end

    change_table :assignment_logs do |t|
      t.index :period_start
      t.index :period_end
      t.index :submitted_at
      t.index :termination_submitted_at
      t.index :termination_verified_at
    end

    change_table :group_assignments do |t|
      t.index :period_start
      t.index :period_end
      t.index :active
      t.index :submitted_at
      t.index :termination_submitted_at
      t.index :termination_verified_at
    end

    change_table :group_offers do |t|
      t.index :search_volunteer
      t.index :period_start
      t.index :period_end
    end

    add_index :hours, :meeting_date

    change_table :volunteers do |t|
      t.index :birth_year
      t.index :salutation
      t.index :nationality
      t.index :acceptance
      t.index :external
      t.index :accepted_at
      t.index :rejected_at
      t.index :resigned_at
      t.index :undecided_at
      t.index :active
      t.index :activeness_might_end
      t.index :invited_at
    end

    change_table :clients do |t|
      t.index :birth_year
      t.index :nationality
      t.index :salutation
      t.index :acceptance
      t.index :resigned_at
      t.index :accepted_at
      t.index :rejected_at
    end

    change_table :contacts do |t|
      t.index :postal_code
      t.index :external
    end
  end
end
