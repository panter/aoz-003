FactoryBot.define do
  sequence :iban do |n|
    'CH%02d %04d %04d %04d %04d %d' % [
      rand(99),
      rand(9999),
      rand(9999),
      rand(9999),
      n,
      rand(9)
    ]
  end
end
