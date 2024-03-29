# frozen_string_literal: true

# Summary of recent activity across the whole app
class Dashboard
  def recent_uploads_by_provider
    recent_uploads_by_provider = Upload.recent.where('created_at > ?', 30.days.ago).group_by(&:organization)
    # Find any providers that didn't have uploads in the last 30 days
    recent_inactive_orgs = Organization.providers - recent_uploads_by_provider.keys

    # Add inactive providers into the returned hash
    # Populate their last upload with upload outside the 30 day window, if one exists
    recent_inactive_orgs.each do |org|
      recent_uploads_by_provider.merge!({ org => org.most_recent_upload })
    end

    recent_uploads_by_provider
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
