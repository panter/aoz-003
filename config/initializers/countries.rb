ISO3166::Data.register(
  alpha2: 'XK',
  un_locode: 'XK',
  name: 'Kosovo',
  translations: {
    'en' => 'Kosovo',
    'de' => 'Kosovo'
  }
)

ISO3166::Data.register(
  alpha2: 'TI',
  un_locode: 'TI',
  name: 'Tibet',
  translations: {
    'en' => 'Tibet',
    'de' => 'Tibet'
  }
)

ISO3166::Country.new('XK').name == 'Kosovo'
ISO3166::Country.new('TI').name == 'Tibet'

ISO3166.configure do |config|
  config.locales = [:en, :de]
end
