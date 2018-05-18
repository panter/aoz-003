class ChangeWorkingPercentType < ActiveRecord::Migration[5.1]
  def up
    # store old values before converting string column to integer
    ids_values = Volunteer.pluck :id, :working_percent
    Volunteer.update_all working_percent: nil
    change_column :volunteers, :working_percent, 'integer USING CAST(working_percent AS integer)', null: true

    # save old working_percent values back as integers
    ids_values.each do |id_value|
      id = id_value[0]
      value = id_value[1]&.match('[0-9]+').to_s.to_i
      value = value == 0 ? nil : value
      Volunteer.where(id: id).first.update(working_percent: value)
    end
  end

  def down
    change_column :volunteers, :working_percent, :string
  end
end
