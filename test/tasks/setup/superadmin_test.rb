require 'test_helper'

class SuperadminTest < ActiveSupport::TestCase
  setup do
    Aoz::Application.load_tasks
  end

  test "should not generate superadmin without email param" do
    assert_equal User.count, 0

    silenced { Rake::Task['setup:superadmin'].invoke }

    assert_equal User.count, 0
  end

  test "generate superadmin with email param" do
    user_count = User.count + 1

    ENV['email'] = 'superadmin@aoz.com'
    Rake::Task['setup:superadmin'].invoke

    assert_equal User.count, user_count
  end

  def silenced
    $stdout = StringIO.new

    yield
  ensure
    $stdout = STDOUT
  end
end
