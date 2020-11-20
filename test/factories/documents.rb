# rubocop:disable Style/MixinUsage
include ActionDispatch::TestProcess
# rubocop:enable Style/MixinUsage

FactoryBot.define do
  factory :document do
    title { FFaker::Name }
    category1 { FFaker::Name }
    category2 { FFaker::Name }
    category3 { FFaker::Name }
    category4 { FFaker::Name }
    file do
      fixture_file_upload(
        File.join(Rails.root, 'test/fixtures/sample.pdf'), 'application/pdf'
      )
    end
  end
end
