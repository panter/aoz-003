class RenameAndereGroupOffer < ActiveRecord::Migration[5.1]
  def up
    cat = GroupOfferCategory.find_by('category_name = ? ', 'Andere')
    cat.update(category_name: 'Anderes / auf Inserat:') if cat
  end
end
