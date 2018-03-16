FactoryBot.define do
  factory :group_offer do
    association :creator, factory: :user_fake_email
    association :department

    title { FFaker::Lorem.sentence }
    necessary_volunteers 5
    offer_type :internal_offer

    after(:build) do |group_offer|
      if GroupOfferCategory.any?
        group_offer.group_offer_category ||= GroupOfferCategory.all.sample
      else
        group_offer.group_offer_category = create(:group_offer_category)
      end
    end
  end
end
