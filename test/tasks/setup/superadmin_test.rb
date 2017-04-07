require 'test_helper'

class SuperadminTest < ActiveSupport::TestCase
  setup do
    Aoz::Application.load_tasks
  end

  test "generate superadmin without email param" do
    assert_equal User.count, 0

    silenced { Rake::Task['setup:superadmin'].invoke }

    assert_equal User.count, 0
  end

  test "generate superadmin with email param and role param" do
    assert_equal User.count, 0

    ENV['email'] = 'superadmin@aoz.com'
    ENV['role'] = 'superadmin'
    Rake::Task['setup:superadmin'].invoke

    assert_equal User.count, 1
  end

  def silenced
    $stdout = StringIO.new

    yield
  ensure
    $stdout = STDOUT
  end
end
