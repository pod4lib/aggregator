# frozen_string_literal: true

# Controller for managing permitted downloaders (organizations and groups) for an organization
class DownloadersController < ApplicationController
  load_and_authorize_resource :organization
  load_and_authorize_resource through: :organization

  def index; end

  def create
    authorize! :control_access, @organization

    downloader = Downloader.find_or_create_by(create_downloader_params)
    respond_to do |format|
      format.turbo_stream { render 'success', locals: { resource: downloader.resource } }
      format.html { redirect_to organization_downloaders_path(@organization), notice: I18n.t('downloaders.create.success') }
    end
  end

  def destroy
    authorize! :control_access, @organization

    resource = @downloader.resource
    @downloader.destroy
    respond_to do |format|
      format.turbo_stream { render 'success', locals: { resource: resource } }
      format.html { redirect_to organization_downloaders_path(@organization), notice: I18n.t('downloaders.destroy.success') }
    end
  end

  private

  def create_downloader_params
    params.permit(:resource_type, :resource_id).merge(organization: @organization)
  end
end
