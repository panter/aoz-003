FactoryBot.define do
  factory :document do
    title { FFaker::Name }
    category1 { FFaker::Name }
    category2 { FFaker::Name }
    category3 { FFaker::Name }
    category4 { FFaker::Name }
    file { File.new(File.join(Rails.root, 'test/fixtures/sample.pdf')) }
  end
end
