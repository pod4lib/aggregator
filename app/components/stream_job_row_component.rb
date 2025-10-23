# frozen_string_literal: true

# Stream job status component
class StreamJobRowComponent < ViewComponent::Base
  def initialize(job, status)
    @job = job
    @status = status
    super()
  end
  attr_reader :job, :status

  delegate :datetime_display_format, :local_time, to: :helpers

  def resource
    gid = job.arguments['arguments'].first['_aj_globalid']
    @resource ||= GlobalID::Locator.locate(gid)
  end

  def resource_label
    return resource.filename if resource.is_a? ActiveStorage::Blob

    resource.name || resource.slug
  end
end
