require 'test_helper'

class DocumentsControllerPath < ActionDispatch::IntegrationTest
  setup do
    @superadmin = create :user, :with_clients,
      :with_department, role: 'superadmin'
    @social_worker = create :user, :with_clients,
      :with_department, role: 'social_worker'
    @department_manager = create :department_manager
  end

  test 'superadmin can submit new document' do
    login_as @superadmin
    path = File.join(Rails.root, 'test/fixtures/sample.pdf')
    file = fixture_file_upload(path, 'application/pdf')
    params = {  document: { title: 't', category1: 'c', file: file } }
    assert_difference 'Document.count', 1 do
      post documents_path, params: params
    end
  end

  test 'superadmin can edit document' do
    document = create :document
    login_as @superadmin
    params = {  document: { title: 'new', category1: 'c', category2: 'a' } }
    patch document_path(document), params: params
    assert Document.find(document.id).category2, 'c'
    assert Document.find(document.id).title, 'new'
  end

  test 'superadmin can destroy document' do
    document = create :document
    login_as @superadmin
    assert_difference 'Document.count', -1 do
      delete document_path(document)
    end
  end

  test 'others cannot destroy document' do
    document = create :document
    count = Document.count
    login_as @social_worker
    delete document_path(document)
    assert count, Document.count
  end
end
