ISO3166::Data.register(
  alpha2: 'KO',
  un_locode: 'KO',
  name: 'Kosovo',
  translations: {
    'de' => 'Kosovo'
  }
)

ISO3166::Data.register(
  alpha2: 'TI',
  un_locode: 'TI',
  name: 'Tibet',
  translations: {
    'de' => 'Tibet'
  }
)

ISO3166::Country.new('KO').name == 'Kosovo'
ISO3166::Country.new('TI').name == 'Tibet'

ISO3166.configure do |config|
  config.locales = [:de]
end
