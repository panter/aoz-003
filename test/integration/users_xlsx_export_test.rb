require 'test_helper'

class UsersXlsxExportTest < ActionDispatch::IntegrationTest
  include ApplicationHelper
  def setup
    User.with_deleted.map(&:really_destroy!)
    @superadmin = create :user, role: 'superadmin'
    login_as @superadmin
    @social_worker = create :social_worker
    @department_manager = create :department_manager
    @volunteer = create :volunteer
    User.with_deleted
        .where.not(id: [@volunteer.user.id, @department_manager.id, @social_worker.id, @superadmin.id])
        .map(&:really_destroy!)
  end

  def assert_user_xls_row(wb, subject_user, row)
    contact = subject_user.profile&.contact || subject_user.volunteer.contact
    assert_equal subject_user.id.to_s, wb.cell(row, 1).to_s
    assert_xls_cols_equal(wb, row, 1, contact.full_name, contact.street, contact.extended,
      contact.postal_code,contact.city, contact.primary_phone)
    assert_xls_cols_equal(wb, row, 7, subject_user.email)
  end

  test 'filtering volunteer users has only volunteer in xls' do
    wb = get_xls_from_response(users_url(format: :xlsx, q: { role_eq: 'volunteer' }))
    assert_user_xls_row(wb, @volunteer.user, 2)
    assert_xls_row_empty(wb, 3)
  end

  test 'filtering volundepartment_managerteer users has only volunteer in xls' do
    wb = get_xls_from_response(users_url(format: :xlsx, q: { role_eq: 'department_manager' }))
    assert_user_xls_row(wb, @department_manager, 2)
    assert_xls_row_empty(wb, 3)
  end

  test 'filtering social_worker users has only volunteer in xls' do
    wb = get_xls_from_response(users_url(format: :xlsx, q: { role_eq: 'social_worker' }))
    assert_user_xls_row(wb, @social_worker, 2)
    assert_xls_row_empty(wb, 3)
  end

  test 'filtering superadmin users has only volunteer in xls' do
    wb = get_xls_from_response(users_url(format: :xlsx, q: { role_eq: 'superadmin' }))
    assert_user_xls_row(wb, @superadmin, 2)
    assert_xls_row_empty(wb, 3)
  end

  # TODO: Flappy test
  # test 'without filter there are all users in the xlsx' do
  #   wb = get_xls_from_response(users_url(format: :xlsx))
  #   assert_xls_cols_equal(wb, 1, 0, 'id', 'Name', 'Strasse', 'Adresszusatz', 'PLZ', 'Ort',
  #     'Telefonnummer', 'Email')
  #   assert_user_xls_row(wb, @volunteer.user, 2)
  #   assert_user_xls_row(wb, @department_manager, 3)
  #   assert_user_xls_row(wb, @social_worker, 4)
  #   assert_user_xls_row(wb, @superadmin, 5)
  # end
end
