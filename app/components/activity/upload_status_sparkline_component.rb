# frozen_string_literal: true

module Activity
  # Uploads activity table showing recent upload statuses
  class UploadStatusSparklineComponent < ViewComponent::Base
    def initialize(organization:, uploads:)
      @organization = organization
      @uploads = uploads
      super()
    end

    def sparklines
      safe_join((30.days.ago.to_date..Time.zone.today).map do |date|
        daily_uploads = uploads_by_date[date] || []
        if daily_uploads.empty?
          tag.span('', class: 'sparkline-bar', aria: { hidden: true })
        else
          upload_sparkline_tag(daily_uploads, href: organization_path(@organization, created_at: date))
        end
      end)
    end

    def uploads_by_date
      @uploads.group_by { |upload| upload.created_at.to_date }
    end

    def upload_sparkline_tag(daily_uploads, href: nil)
      # Show the worst status of the day
      statuses = daily_uploads.index_by(&:metadata_status)

      timestamp = daily_uploads.first.created_at.strftime('%Y-%m-%d')

      if statuses.key?('invalid') && statuses.key?('success')
        link_to '', href, class: 'border-start border-end sparkline-bar bg-striped-success-danger',
                          title: "Mixed results on #{timestamp}"
      elsif statuses.key?('invalid')
        link_to '', href, class: 'border-start border-end sparkline-bar bg-danger', title: "Failed on #{timestamp}"
      elsif statuses.key?('success')
        link_to '', href, class: 'border-start border-end sparkline-bar bg-success', title: "Success on #{timestamp}"
      end
    end
  end
end
