class CreateVolunteers < ActiveRecord::Migration[5.1]
  def change
    create_table :volunteers do |t|
      t.text :volunteer_experience_desc
      t.text :education
      t.text :motivation
      t.text :expectations
      t.text :strengths
      t.text :interests
      t.text :rejection_text
      t.text :detailed_description
      t.text :other_offer_desc
      t.text :own_kids

      t.string :salutation
      t.string :profession
      t.string :working_percent
      t.string :rejection_type
      t.string :nationality
      t.string :additional_nationality
      t.string  :bank, :string
      t.string  :iban, :string
      t.string :state, default: 'registered'

      t.boolean :waive, default: false
      t.boolean :experience, default: false
      t.boolean :man, default: false
      t.boolean :woman, default: false
      t.boolean :family, default: false
      t.boolean :kid, default: false
      t.boolean :sport, default: false
      t.boolean :creative, default: false
      t.boolean :music, default: false
      t.boolean :culture, default: false
      t.boolean :training, default: false
      t.boolean :german_course, default: false
      t.boolean :teenagers, default: false
      t.boolean :children, default: false
      t.boolean :intro_course, default: false
      t.boolean :trial_period, default: false
      t.boolean :doc_sent, default: false
      t.boolean :bank_account, default: false
      t.boolean :evaluation, default: false
      t.boolean :flexible, default: false
      t.boolean :morning, default: false
      t.boolean :afternoon, default: false
      t.boolean :evening, default: false
      t.boolean :workday, default: false
      t.boolean :weekend, default: false
      t.boolean :dancing, default: false
      t.boolean :health, default: false
      t.boolean :cooking, default: false
      t.boolean :excursions, default: false
      t.boolean :women, default: false
      t.boolean :unaccompanied, default: false
      t.boolean :zurich, default: false
      t.boolean :other_offer, default: false

      t.date :birth_year

      t.references :user, foreign_key: true
      t.references :registrar, references: :users
      t.attachment :avatar

      t.datetime :deleted_at, index: true
      t.timestamps
    end

    add_foreign_key :volunteers, :volunteers, column: :registrar_id
  end
end
