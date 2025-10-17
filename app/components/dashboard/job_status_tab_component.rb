# frozen_string_literal: true

module Dashboard
  # Job status tab showing current job statuses by provider
  class JobStatusTabComponent < ViewComponent::Base
    def job_status_groups_by_provider
      @job_status_groups_by_provider ||= Organization.providers.index_with do |org|
        org.default_stream.job_tracker_status_groups
      end
    end
  end
end
