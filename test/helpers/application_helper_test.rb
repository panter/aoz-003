require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'nationality_name_helper_does_not_crash_on_record_with_invalid_country_letters' do
    valid_nationality_client = create :client, nationality: 'ER'
    invalid_nationality_client = create :client, nationality: 'KO'
    assert_match '', nationality_name(nil)
    assert_match 'Eritrea', nationality_name(valid_nationality_client.nationality)
    assert_match '', nationality_name(invalid_nationality_client.nationality)
  end
end
