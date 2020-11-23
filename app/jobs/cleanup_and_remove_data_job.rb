# frozen_string_literal: true

# Cleanup data per data retention policy
class CleanupAndRemoveDataJob < ApplicationJob
  def self.enqueue_all
    Organization.find_each { |org| CleanupAndRemoveDataJob.perform_later(org) }
  end

  # rubocop:disable Metrics/AbcSize
  def perform(organization)
    # Keep the most recent ("default") stream from each organization
    # Keep older streams for an organization for a quarter after it is no longer the default.
    organization
      .streams
      .where(default: false)
      .where.not(updated_at: (Time.zone.now - 3.months)..Time.zone.now)
      .find_each(&:archive)
    # Keep the 2 most recent normalized dumps
    last_two = organization.default_stream.normalized_dumps.last(2)
    (organization.default_stream.normalized_dumps - last_two).map(&:destroy)
    # Keep deltas for an additional month (1 whole quarter)
    # Keep deleted record information for 6 months after it is removed
    organization
      .streams
      .archived
      .where.not(updated_at: (Time.zone.now - 6.months)..Time.zone.now)
      .destroy_all
  end
  # rubocop:enable Metrics/AbcSize
end
