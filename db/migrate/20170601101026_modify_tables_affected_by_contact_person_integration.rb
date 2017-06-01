class ModifyTablesAffectedByContactPersonIntegration < ActiveRecord::Migration[5.1]
  def change
    change_table :language_skills do |t|
      t.remove :languageable_id
      t.remove :languageable_type
      t.references :people
    end

    change_table :relatives do |t|
      t.remove :relativeable_id
      t.remove :relativeable_type
      t.remove :first_name
      t.remove :last_name
      t.remove :date_of_birth
      t.references :people
    end

    change_table :schedules do |t|
      t.remove :scheduleable_id
      t.remove :scheduleable_type
      t.references :people
    end

    change_table :clients do |t|
      t.remove :first_name
      t.remove :last_name
      t.remove :zip
      t.remove :city
      t.remove :street
      t.remove :phone
      t.remove :email
      t.remove :gender
      t.remove :date_of_birth
      t.remove :nationality
      t.remove :education
      t.remove :hobbies
      t.remove :interests
    end

    change_table :volunteers do |t|
      t.remove :first_name
      t.remove :last_name
      t.remove :date_of_birth
      t.remove :gender
      t.remove :street
      t.remove :zip
      t.remove :city
      t.remove :nationality
      t.remove :additional_nationality
      t.remove :email
      t.remove :phone
      t.remove :profession
      t.remove :education
      t.remove :interests
      t.remove :avatar_file_name
      t.remove :avatar_content_type
      t.remove :avatar_file_size
      t.remove :avatar_updated_at
    end

    change_table :profiles do |t|
      t.remove :first_name
      t.remove :last_name
      t.remove :phone
      t.remove :address
      t.remove :profession
      t.remove :avatar_file_name
      t.remove :avatar_content_type
      t.remove :avatar_file_size
      t.remove :avatar_updated_at
      t.remove :monday
      t.remove :tuesday
      t.remove :wednesday
      t.remove :thursday
      t.remove :friday
    end
  end
end
