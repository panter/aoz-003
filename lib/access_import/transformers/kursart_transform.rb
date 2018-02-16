class KursartTransform < Transformer
  # could be needed relations

  def prepare_attributes(kursart)
    {
      category_name: kursart[:t_Bezeichnung]
    }.merge(import_attributes(:tbl_Kursarten, kursart[:pk_Kursart], kursart: kursart))
  end

  def get_or_create_by_import(kursart_id, kursart = nil)
    return @entity if get_import_entity(:group_offer_category, kursart_id).present?
    kursart ||= @kursarten.find(kursart_id)
    group_offer_category = GroupOfferCategory.create!(prepare_attributes(kursart))
    update_timestamps(group_offer_category, kursart[:d_MutDatum])
  end

  def import_all
    @kursarten.all.map do |key, kurs|
      get_or_create_by_import(key, kurs)
    end
  end
end
