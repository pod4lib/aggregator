# frozen_string_literal: true

# Customize devise_invitable's controller with support for inviting a new
# or existing user to an organization
class SiteUsersController < ApplicationController
  load_and_authorize_resource :user, parent: false

  def index
    @users = @users.includes(:organizations).order('organizations.name', :email)
  end

  # rubocop:disable Metrics/AbcSize
  def update
    @user.remove_role params[:remove_role] if params[:remove_role].present?
    @user.add_role params[:add_role] if params[:add_role].present?

    respond_to do |format|
      format.html { redirect_to site_users_url, notice: 'User role was successfully updated.', status: :see_other }
      format.json { head :no_content }
    end
  end
  # rubocop:enable Metrics/AbcSize
end
