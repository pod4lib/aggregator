# frozen_string_literal: true

module Dashboard
  # Uploads activity table showing recent upload statuses
  class UploadStatusSparklineComponent < ViewComponent::Base
    def initialize(uploads:)
      @uploads = uploads
      super()
    end

    def sparklines
      safe_join((30.days.ago.to_date..Time.zone.today).map do |date|
        daily_uploads = uploads_by_date[date] || []
        if daily_uploads.empty?
          tag.span('', class: 'sparkline-bar', aria: { hidden: true })
        else
          upload_sparkline_tag(daily_uploads)
        end
      end)
    end

    def uploads_by_date
      @uploads.group_by { |upload| upload.created_at.to_date }
    end

    def upload_sparkline_tag(daily_uploads)
      # Show the worst status of the day
      statuses = daily_uploads.index_by(&:metadata_status)

      timestamp = daily_uploads.first.created_at.strftime('%Y-%m-%d')

      if statuses.key?('invalid') && statuses.key?('success')
        tag.span('', class: 'border sparkline-bar bg-striped-success-danger',
                     title: "Mixed results on #{timestamp}")
      elsif statuses.key?('invalid')
        tag.span('', class: 'border sparkline-bar bg-danger',
                     title: "Failed on #{timestamp}")
      elsif statuses.key?('success')
        tag.span('', class: 'border sparkline-bar bg-success',
                     title: "Success on #{timestamp}")
      end
    end
  end
end
