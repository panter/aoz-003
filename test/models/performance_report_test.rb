require 'test_helper'

class GroupOfferCategoryTest < ActiveSupport::TestCase
  def setup
    @today = Time.zone.now.to_date
    @year_ago = 1.year.ago.to_date
    @user = create :user

    # volunteer zuerich new and active this year
    @v_z_this_y = create :volunteer_z, created_at: @today.beginning_of_year
    @c_z_this_y = create :client_z, user: @user, created_at: @today.beginning_of_year
    create_assignment(:a_this_y, @v_z_this_y, @c_z_this_y, @today.beginning_of_year + 2)

    # volunteer zuerich active last year, inactive now
    @v_z_last_y = create :volunteer_z, created_at: @year_ago.beginning_of_year + 10
    @c_z_last_y = create :client_z, user: @user, created_at: @year_ago.beginning_of_year + 10
    create_assignment(:a_last_y, @v_z_last_y, @c_z_last_y, @year_ago, @year_ago.end_of_year)

    # volunteer zuerich created last year, active this and last year
    @v_z_last_y_still_active = create :volunteer_z, created_at: @year_ago.beginning_of_year + 10
    @c_z_last_y_still_active = create :client_z, user: @user,
      created_at: @year_ago.beginning_of_year + 10
    create_assignment(:a_this_y, @v_z_last_y_still_active, @c_z_last_y_still_active, @year_ago)

    # @v_internal_active_last_y = create :volunteer
    # @c_zuerich_last_y = create :client_z
  end

  test 'empty' do
    this_year_report = PerformanceReport.new(period_start: @today.beginning_of_year,
      period_end: @today.end_of_year, user: @user)
    this_year_report.save

    last_year_report = PerformanceReport.new(period_start: @year_ago.beginning_of_year,
      period_end: @year_ago.end_of_year, user: @user)
    last_year_report.save
  end

  def create_assignment(title, volunteer, client, period_start = nil, period_end = nil)
    period_start ||= @today.beginning_of_year
    assignment = create :assignment, volunteer: volunteer, client: client, creator: @user,
      period_start: period_start, period_end: period_end, created_at: period_start
    return assignment unless title
    instance_variable_set("@#{title}", assignment)
  end
end
