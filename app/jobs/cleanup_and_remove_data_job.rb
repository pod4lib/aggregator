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
      .where.not(updated_at: 3.months.ago..Time.zone.now)
      .find_each(&:archive)
    # Keep the 2 most recent published normalized full dumps
    last_two = organization.default_stream.full_dumps.published.last(2)
    (organization.default_stream.full_dumps.published - last_two).map(&:destroy)
    # Keep deltas for an additional month (and at least 1 whole quarter)
    organization.default_stream.delta_dumps.where(created_at: ([(last_two.first&.created_at || Time.zone.now) - 1.month,
                                                                3.months.ago].max)..).map(&:destroy)
    # Keep deleted record information for 6 months after it is removed
    organization
      .streams
      .archived
      .where.not(updated_at: 6.months.ago..Time.zone.now)
      .destroy_all
  end
  # rubocop:enable Metrics/AbcSize
end
