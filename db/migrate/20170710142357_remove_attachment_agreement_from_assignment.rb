class RemoveAttachmentAgreementFromAssignment < ActiveRecord::Migration[5.1]
  def change
    remove_attachment :assignments, :agreement
  end
end
