# frozen_string_literal: true

# Stream job status component
class StreamsJobStatusComponent < ViewComponent::Base
  def initialize(stream)
    @stream = stream
    super()
  end

  attr_reader :stream

  def job_status_tabs_collapse(tab_expanded, jobs_count)
    !tab_expanded && jobs_count.positive? ? 'show' : 'collapsed'
  end
end
