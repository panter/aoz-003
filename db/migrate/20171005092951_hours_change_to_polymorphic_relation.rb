class HoursChangeToPolymorphicRelation < ActiveRecord::Migration[5.1]
  def up
    add_reference :hours, :hourable, polymorphic: true, index: true
    # Convert existing relations to Assignment to polymorphic relation
    Hour.with_deleted.each do |hour|
      hour.update(hourable_type: 'Assignment', hourable_id: hour.assignment_id)
    end
    remove_belongs_to :hours, :assignment
  end

  def down
    add_reference :hours, :assignment, foreign_key: true
    # Convert existing polymorphic Assignment relation back to direct assignment relation
    Hour.with_deleted.where(hourable_type: 'Assignment').each do |hour|
      hour.update(assignment_id: hour.hourable_id)
    end
    # destroy existing hours with relation to Group offer
    Hour.with_deleted.where(hourable_type: 'GroupOffer').map(&:really_destroy!)
    remove_reference :hours, :hourable
  end
end
