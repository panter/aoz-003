require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'database_cleaner'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include Warden::Test::Helpers

  DatabaseCleaner.strategy = :transaction

  def before_setup
    super
    DatabaseCleaner.start
  end

  def after_teardown
    DatabaseCleaner.clean
    super
  end

  def permit(current_user, record, action)
    self.class.to_s.gsub(/Test/, '')
        .constantize.new(current_user, record)
        .public_send("#{action}?")
  end

  def forbid(current_user, record, action)
    !permit(current_user, record, action)
  end

  def assert_permit(user, record, *permissions)
    get_permissions(permissions).each do |permission|
      policy = Pundit.policy!(user, record)
      assert policy.public_send(permission),
        "Expected #{policy.class.name} to grant #{permission} "\
          "on #{record} for #{user} but it didn't"
    end
  end

  def refute_permit(user, record, *permissions)
    get_permissions(permissions).each do |permission|
      policy = Pundit.policy!(user, record)
      refute policy.public_send(permission),
        "Expected #{policy.class.name} not to grant #{permission} "\
          "on #{record} for #{user} but it did"
    end
  end

  private

  # borrowed from Pundit::PolicyFinder
  def find_param_key(record)
    if record.respond_to?(:model_name)
      record.model_name.param_key.to_s
    elsif record.is_a?(Class)
      record.to_s.demodulize.underscore
    else
      record.class.to_s.demodulize.underscore
    end
  end

  def get_permissions(permissions)
    return permissions if permissions.present?

    name = calling_method

    raise(MissingBlockParameters) if name.start_with?('block')

    name[5..-1].split(PolicyAssertions.config.separator).map { |a| "#{a}?" }
  end

  def calling_method
    if PolicyAssertions.config.ruby_version > 1
      caller_locations(3, 1)[0].label
    else
      caller[2][/`.*'/][1..-2]
    end
  end
end
