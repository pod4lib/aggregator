# frozen_string_literal: true

# Class representing a downloader relationship between an organization and
# resources (a group or another organization) that are allowed to download from it
class Downloader < ApplicationRecord
  has_paper_trail

  belongs_to :organization
  belongs_to :resource, polymorphic: true

  after_commit on: %i[create destroy] do
    update_access_summary_alert
  end

  private

  def update_access_summary_alert
    broadcast_replace_to organization,
                         target: "access_summary_alert_organization_#{organization.id}",
                         html: Downloaders::AccessSummaryAlertComponent.new(organization: organization)
                                                                       .render_in(ActionController::Base.new.view_context),
                         locals: { organization: organization }
  end
end
