# frozen_string_literal: true

# Controller for managing permitted downloaders (organizations and groups) for an organization
class DownloadersController < ApplicationController
  load_and_authorize_resource :organization
  load_and_authorize_resource through: :organization

  def index
    @other_organizations = Organization.accessible_by(current_ability).where.not(id: @organization.id)
    @groups = Group.accessible_by(current_ability)
  end

  def create
    authorize! :control_access, @organization

    Downloader.find_or_create_by(create_downloader_params)
    redirect_to organization_downloaders_path(@organization),
                notice: I18n.t('downloaders.create.success')
  end

  def destroy
    authorize! :control_access, @organization

    @downloader.destroy
    redirect_to organization_downloaders_path(@organization),
                notice: I18n.t('downloaders.destroy.success')
  end

  private

  def create_downloader_params
    params.permit(:resource_type, :resource_id).merge(organization: @organization)
  end
end
