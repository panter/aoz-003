require 'net/sftp'
require 'tempfile'

namespace :coplaner do
  desc 'Create Coplaner XLSX file and upload it via SFTP'
  task upload: :environment do
    start_time = Time.zone.now
    filename = "aoz_freiwillige_#{Time.zone.now.strftime('%Y-%m-%dT%H%M%S')}.xlsx"
    puts <<~HEREDOC
      Starting to render the Coplaner XLSX file: #{filename}

      This may take up to a minute or depending on the host system and DB size even longer than that.

      Just a moment please...

    HEREDOC
    @volunteers = Volunteer.all.order(:id)
    @clients = Client.all.order(:id)
    @assignments = Assignment.all.order(:id)
    @group_offers = GroupOffer.all.order(:id)
    @group_assignments = GroupAssignment.all.order(:id)
    @hours = Hour.all.order(:id)
    @events = Event.all.order(:id)
    @event_volunteers = EventVolunteer.all.order(:id)
    @billing_expenses = BillingExpense.all.order(:id)
    @departments = Department.all.order(:id)
    @group_offer_categories = GroupOfferCategory.all.order(:id)
    action_view = ActionView::Base.new(ActionController::Base.view_paths, {
      volunteers: @volunteers,
      clients: @clients,
      assignments: @assignments,
      group_offers: @group_offers,
      group_assignments: @group_assignments,
      hours: @hours,
      events: @events,
      event_volunteers: @event_volunteers,
      billing_expenses: @billing_expenses,
      departments: @departments,
      group_offer_categories: @group_offer_categories
    })
    action_view.class_eval do
      # include any needed helpers (for the view)
      include ApplicationHelper
      include XlsHelper
      include FormatHelper
    end
    rendered_xlsx = action_view.render template: 'coplaners/index.xlsx.axlsx'
    tempfile = Tempfile.new(filename)
    tempfile.write(rendered_xlsx)
    puts <<~HEREDOC

      Successfully rendered the Excel file

      Filename: #{filename}
      Size: #{tempfile.size / 1024} Kb
      Render time: #{Time.zone.now - start_time} seconds

    HEREDOC
    sftp_credentials = {
      host: ENV['SFTP_HOST'],
      user: ENV['SFTP_USER'],
      password: ENV['SFTP_PASS']
    }
    if sftp_credentials.values.map(&:blank?).any?
      raise <<~HEREDOC
        Missing required SFTP credetials to upload the coplaner XLSX file.

        These are the required ENV variables:

        - SFTP_HOST
        - SFTP_USER
        - SFTP_PASS

      HEREDOC
    end

    puts <<~HEREDOC

      Uploading the XLSX file to: #{sftp_credentials[:host]}

    HEREDOC
    Net::SFTP.start(ENV['SFTP_HOST'], ENV['SFTP_USER'], password: ENV['SFTP_PASS']) do |sftp|
      sftp.upload!(tempfile.path, filename)
    end
    tempfile.unlink
  end
end
