require 'test_helper'
class DocumentPolicyTest < PolicyAssertions::Test
  def setup
    @superadmin = create :user, :with_clients, :with_department, role: 'superadmin'
    @social_worker = create :user, :with_clients, role: 'social_worker'
    @department_manager = create :department_manager
    @document = create :document
    @file = File.new(File.join(Rails.root, 'test/fixtures/sample.pdf'))
  end

  test 'only superadmin can create document' do
    document_params = {
      title: 't', category1: 'c', file: @file
    }
    assert_permit @superadmin, Document.new(document_params), 'create?', 'new?', 'destroy?', 'edit?'
  end

  test 'others can only view' do
    refute_permit(
      @social_worker, @document,
      'new?', 'edit?', 'create?', 'update?', 'destroy?'
    )
    refute_permit(
      @department_manager, @document,
      'new?', 'edit?', 'create?', 'update?', 'destroy?'
    )

    assert_permit(
      @department_manager, @document,
      'show?', 'index?'
    )
    assert_permit(
      @social_worker, @document,
      'show?', 'index?'
    )
  end
end
