# frozen_string_literal: true

# Summary of recent activity across the whole app
class Dashboard
  def recent_uploads_by_provider
    Rails.cache.fetch(:recent_uploads_by_provider, expires_in: 1.hour) do
      Upload.recent.where('created_at > ?', 30.days.ago).group_by(&:organization)
    end
  end

  def job_status_groups_by_provider
    Rails.cache.fetch(:job_status_groups_by_provider, expires_in: 1.hour) do
      Organization.providers.index_with { |org| org.default_stream.job_tracker_status_groups }
    end
  end

  def normalized_data_by_provider
    Rails.cache.fetch(:normalized_data_by_provider, expires_in: 1.hour) do
      Organization.providers.index_with { |org| org.default_stream.normalized_dumps.full_dumps.last }
    end
  end

  def users_by_organization
    Rails.cache.fetch(:users_by_provider, expires_in: 1.hour) do
      Organization.all.index_with(&:users)
    end
  end
end
