# frozen_string_literal: true

# Cleanup data per data retention policy
class PromoteStreamToDefaultJob < ApplicationJob
  def perform(stream, effective_date: Time.zone.now)
    current_default_stream = stream.organization.default_stream

    return unless stream.pending? && current_default_stream != stream

    GenerateFullDumpJob.perform_now(stream, effective_date: effective_date) if stream.full_dumps.published.none?

    # Run manually for now:
    # GenerateInterstreamDeltaDumpJob.perform_now(
    #   stream.organization.default_stream, stream, effective_date: effective_date
    # )

    stream.make_default
  end
end
