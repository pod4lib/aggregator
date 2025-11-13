# frozen_string_literal: true

# Customize devise_invitable's controller with support for inviting a new
# or existing user to an organization
class OrganizationUsersController < ApplicationController
  load_and_authorize_resource :organization
  before_action :load_user, except: [:index]

  def index; end

  # rubocop:disable Metrics/AbcSize
  def update
    authorize! :administer, @organization
    @user.remove_role(params[:remove_role], @organization) if params[:remove_role].present?
    @user.add_role(params[:add_role], @organization) if params[:add_role].present?

    respond_to do |format|
      format.html do
        redirect_to organization_users_url(@organization), notice: 'User role was successfully updated.', status: :see_other
      end
      format.json { head :no_content }
    end
  end
  # rubocop:enable Metrics/AbcSize

  def destroy
    authorize! :administer, @organization
    @user.destroy

    respond_to do |format|
      format.html do
        redirect_to organization_users_url(@organization), notice: 'User was successfully removed.', status: :see_other
      end
      format.json { head :no_content }
    end
  end

  def load_user
    @user = User.find(params[:id]) || User.new
  end
end
