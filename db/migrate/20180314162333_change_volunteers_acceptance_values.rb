class ChangeVolunteersAcceptanceValues < ActiveRecord::Migration[5.1]
  def up
    Volunteer.transaction do
      invited = Volunteer.where(acceptance: 4)
      accepted = Volunteer.where(acceptance: 1)
      rejected = Volunteer.where(acceptance: 2)
      resigned = Volunteer.where(acceptance: 3)

      invited.update_all(acceptance: 1)
      accepted.update_all(acceptance: 2)
      rejected.update_all(acceptance: 3)
      resigned.update_all(acceptance: 4)
    end
  end

  def down
    Volunteer.transaction do
      invited = Volunteer.where(acceptance: 1)
      accepted = Volunteer.where(acceptance: 2)
      rejected = Volunteer.where(acceptance: 3)
      resigned = Volunteer.where(acceptance: 4)

      invited.update_all(acceptance: 4)
      accepted.update_all(acceptance: 1)
      rejected.update_all(acceptance: 2)
      resigned.update_all(acceptance: 3)
    end
  end
end
