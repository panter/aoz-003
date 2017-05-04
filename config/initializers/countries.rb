ISO3166::Data.register(
  alpha2: "XK",
  name: 'Kosovo',
  translations: {
    'en' => "Kosovo",
    'de' => "Kosovo"
  }
)

ISO3166::Country.new('XK').name == 'Kosovo'

ISO3166.configure do |config|
  config.locales = [:en, :de]
end
