class KursartTransform < Transformer
  # could be needed relations

  def prepare_attributes(kursart)
    {
      category_name: kursart[:t_Bezeichnung],
      import_attributes: access_import(:tbl_Kursarten, kursart[:pk_Kursart], kursart: kursart)
    }
  end

  def get_or_create_by_import(kursart_id, kursart = nil)
    group_offer_category = Import.get_imported(GroupOfferCategory, kursart_id)
    return group_offer_category if group_offer_category.present?
    kursart ||= @kursarten.find(kursart_id)
    group_offer_category = GroupOfferCategory.create!(prepare_attributes(kursart))
    group_offer_category.update(created_at: kursart[:d_MutDatum], updated_at: kursart[:d_MutDatum])
    group_offer_category
  end

  def import_all
    @kursarten.all.map do |key, kurs|
      get_or_create_by_import(key, kurs)
    end
  end
end
