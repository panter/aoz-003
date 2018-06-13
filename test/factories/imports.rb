FactoryBot.define do
  factory :import do
    access_id 2412
    base_origin_entity 'tbl_Personenrollen'
    store { YAML.parse_file('test/factories/volunteers_import_store.yml').to_ruby }
  end
end
