class GroupAssignment < ApplicationRecord
  belongs_to :group_offer
  belongs_to :volunteer
  has_many :group_assignment_logs

  after_save :save_group_assignment_logs,
    if: :saved_change_to_start_date? || :saved_change_to_end_date?
  before_destroy :save_group_assignment_logs

  def save_group_assignment_logs
    group_assignment_logs.create!(group_offer_id: group_offer_id, volunteer_id: volunteer_id,
      group_assignment_id: id, title: group_offer.title, start_date: start_date_before_last_save,
      end_date: end_date_before_last_save, responsible: responsible)
  end
end
