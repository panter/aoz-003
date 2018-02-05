require 'test_helper'
require 'ostruct'
require 'utility/performance_report_generator'

class GroupOfferCategoryTest < ActiveSupport::TestCase
  include PerformanceReportGenerator

  def setup
    DatabaseCleaner.clean
    DatabaseCleaner.start
    @today = Time.zone.today
    @year_ago = 1.year.ago.to_date
    @user = create :user
  end

  test 'group offer counts' do
    volunteer = create :volunteer_with_user
    volunteer.update(created_at: 5.years.ago)
    create_group_offer_entity(:this_year, @today.beginning_of_year + 2, nil, volunteer)
    create_group_offer_entity(:last_year, @year_ago, @year_ago.end_of_year - 2, volunteer)
    create_group_offer_entity(:last_year_still, @year_ago, nil, volunteer)

    this_year_rep = extract_results PerformanceReport.create!(user: @user,
      period_start: @today.beginning_of_year, period_end: @today.end_of_year)
    last_year_rep = extract_results PerformanceReport.create!(user: @user,
      period_start: @year_ago.beginning_of_year, period_end: @year_ago.end_of_year)
  end
end
