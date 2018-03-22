require 'test_helper'

class GroupOffersXlsxExportTest < ActionDispatch::IntegrationTest
  def setup
    @superadmin = create :user
    login_as @superadmin
  end

  test 'xlsx files has the right columns' do
    create :group_offer
    wb = get_xls_from_response(group_offers_url(format: :xlsx))
    assert_xls_cols_equal(
      wb, 1, 0,
      'Status',
      'Bezeichnung',
      'Kategorie',
      'Internes oder externes Gruppenangebot',
      'Standort',
      'Ort',
      'Zeitangaben',
      'Zielpublikum',
      'Organisation',
      'Dauer',
      'FW-Nachfrage',
      'Verantwortliche/r',
      'Freiwillige'
    )
    assert_xls_cols_equal(wb, 2, 1, GroupOffer.first.title)
  end
end
