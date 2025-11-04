# frozen_string_literal: true

module Dashboard
  # Uploads activity table showing recent upload statuses
  class UploadStatusSparklineComponent < ViewComponent::Base
    def initialize(uploads:)
      @uploads = uploads
      super()
    end

    def sparklines # rubocop:disable Metrics/AbcSize
      safe_join((30.days.ago.to_date..Time.zone.today).map do |date|
        daily_uploads = uploads_by_date[date] || []
        if daily_uploads.empty?
          tag.span('', class: 'sparkline-bar', aria: { hidden: true })
        else
          # Show the worst status of the day
          worst_upload = daily_uploads.min_by do |upload|
            case upload.metadata_status
            when 'invalid' then 0
            when 'success' then 2
            else 1
            end
          end

          upload_sparkline_tag(worst_upload)
        end
      end)
    end

    def uploads_by_date
      @uploads.group_by { |upload| upload.created_at.to_date }
    end

    def upload_sparkline_tag(upload)
      case upload.metadata_status
      when 'success'
        tag.span('', class: 'border sparkline-bar bg-success', title: "Success on #{upload.created_at.strftime('%Y-%m-%d')}")
      when 'invalid'
        tag.span('', class: 'border sparkline-bar bg-danger', title: "Failed on #{upload.created_at.strftime('%Y-%m-%d')}")
      end
    end
  end
end
