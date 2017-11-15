class ModifyVolunteerGroupOfferCategories < ActiveRecord::Migration[5.1]
  def change
    remove_column :volunteers, :other_offer, :boolean
    remove_column :volunteers, :dancing, :boolean
    remove_column :volunteers, :health, :boolean
    remove_column :volunteers, :cooking, :boolean
    remove_column :volunteers, :excursions, :boolean
    remove_column :volunteers, :women, :boolean
    remove_column :volunteers, :sport, :boolean
    remove_column :volunteers, :creative, :boolean
    remove_column :volunteers, :music, :boolean
    remove_column :volunteers, :culture, :boolean
    remove_column :volunteers, :training, :boolean
    remove_column :volunteers, :german_course, :boolean
    remove_column :volunteers, :teenagers, :boolean
    remove_column :volunteers, :children, :boolean
    remove_column :volunteers, :zurich, :boolean
    add_column :group_offer_categories, :description, :text
  end
end
