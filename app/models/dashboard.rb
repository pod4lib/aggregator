# frozen_string_literal: true

# Summary of recent activity across the whole app
class Dashboard
  def recent_uploads_by_provider
    Organization.providers.index_with { |org| org.uploads.recent.where('uploads.created_at > ?', 30.days.ago) }
  end

  def job_status_groups_by_provider
    Organization.providers.index_with { |org| org.default_stream.job_tracker_status_groups }
  end

  def normalized_data_by_provider
    Organization.providers.index_with { |org| org.default_stream.normalized_dumps.full_dumps.published.last }
  end

  def users_by_organization
    Organization.all.index_with(&:users)
  end
end
