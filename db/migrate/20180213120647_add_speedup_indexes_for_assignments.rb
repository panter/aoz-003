class AddSpeedupIndexesForAssignments < ActiveRecord::Migration[5.1]
  def change
    change_table :assignments do |t|
      t.index :period_start
      t.index :period_end
      t.index :performance_appraisal_review
      t.index :probation_period
      t.index :home_visit
      t.index :first_instruction_lesson
      t.index :progress_meeting
      t.index :kind
      t.index :submitted_at
      t.index :termination_submitted_at
      t.index :termination_verified_at
    end

    change_table :assignment_logs do |t|
      t.index :period_start
      t.index :period_end
      t.index :performance_appraisal_review
      t.index :probation_period
      t.index :home_visit
      t.index :first_instruction_lesson
      t.index :progress_meeting
      t.index :kind
      t.index :submitted_at
      t.index :termination_submitted_at
      t.index :termination_verified_at
    end

    change_table :group_assignments do |t|
      t.index :period_start
      t.index :period_end
      t.index :responsible
      t.index :active
      t.index :submitted_at
      t.index :termination_submitted_at
      t.index :termination_verified_at
    end

    change_table :group_assignment_logs do |t|
      t.index :period_start
      t.index :period_end
      t.index :responsible
      t.index :submitted_at
      t.index :termination_submitted_at
      t.index :termination_verified_at
    end

    change_table :group_offers do |t|
      t.index :offer_type
      t.index :offer_state
      t.index :volunteer_state
      t.index :necessary_volunteers
      t.index :women
      t.index :men
      t.index :children
      t.index :teenagers
      t.index :unaccompanied
      t.index :all
      t.index :long_term
      t.index :regular
      t.index :short_term
      t.index :workday
      t.index :weekend
      t.index :flexible
      t.index :morning
      t.index :afternoon
      t.index :evening
      t.index :active
      t.index :search_volunteer
      t.index :period_start
      t.index :period_end
    end

    add_index :hours, :meeting_date
    add_index :group_offer_categories, :category_state

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
      t.index :take_more_assignments
      t.index :active
      t.index :activeness_might_end
      t.index :invited_at
    end

    change_table :clients do |t|
      t.index :birth_year
      t.index :nationality
      t.index :permit
      t.index :salutation
      t.index :gender_request
      t.index :age_request
      t.index :other_request
      t.index :flexible
      t.index :morning
      t.index :afternoon
      t.index :evening
      t.index :workday
      t.index :weekend
      t.index :entry_date
      t.index :acceptance
      t.index :resigned_at
      t.index :accepted_at
      t.index :rejected_at
    end

    change_table :contacts do |t|
      t.index :postal_code
      t.index :city
      t.index :primary_email
      t.index :external
    end

  end
end
