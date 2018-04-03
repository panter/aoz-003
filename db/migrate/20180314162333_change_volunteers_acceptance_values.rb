class ChangeVolunteersAcceptanceValues < ActiveRecord::Migration[5.1]
  def up
    Volunteer.transaction do
      invited = Volunteer.where(acceptance: 4).ids
      accepted = Volunteer.where(acceptance: 1).ids
      rejected = Volunteer.where(acceptance: 2).ids
      resigned = Volunteer.where(acceptance: 3).ids

      Volunteer.where(id: invited).update_all(acceptance: 1)
      Volunteer.where(id: accepted).update_all(acceptance: 2)
      Volunteer.where(id: rejected).update_all(acceptance: 3)
      Volunteer.where(id: resigned).update_all(acceptance: 4)
    end
  end

  def down
    Volunteer.transaction do
      invited = Volunteer.where(acceptance: 1).ids
      accepted = Volunteer.where(acceptance: 2).ids
      rejected = Volunteer.where(acceptance: 3).ids
      resigned = Volunteer.where(acceptance: 4).ids

      Volunteer.where(id: invited).update_all(acceptance: 4)
      Volunteer.where(id: accepted).update_all(acceptance: 1)
      Volunteer.where(id: rejected).update_all(acceptance: 2)
      Volunteer.where(id: resigned).update_all(acceptance: 3)
    end
  end
end
