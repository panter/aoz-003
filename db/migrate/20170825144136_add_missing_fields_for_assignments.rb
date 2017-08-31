class AddMissingFieldsForAssignments < ActiveRecord::Migration[5.1]
  def change
    change_table :assignments do |t|
      t.datetime :assignment_start
      t.datetime :assignment_end
      t.datetime :first_instruction_lesson     # ErstUnterricht
      t.datetime :progress_meeting             # Standortgespräch
      t.datetime :home_visit                   # Hausbesuch
      t.datetime :probation_period             # Probezeit
      t.datetime :performance_appraisal_review # Probezeitbericht
      t.string   :short_description            # Kurzbezeichnung
      t.text     :goals                        # Zielsetzung
      t.text     :starting_topic               # Einstiegsthematik
      t.text     :description                  # Beschreibung
    end
  end
end
