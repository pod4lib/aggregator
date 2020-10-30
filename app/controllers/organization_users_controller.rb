# frozen_string_literal: true

# Customize devise_invitable's controller with support for inviting a new
# or existing user to an organization
class OrganizationUsersController < ApplicationController
  load_and_authorize_resource :organization
  before_action :load_user

  def destroy
    authorize! :manage, @organization
    @user.roles.where(resource: @organization).each do |role|
      @user.remove_role role.name, @organization
    end

    respond_to do |format|
      format.html { redirect_to organization_url(@organization), notice: 'User role was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def load_user
    @user = User.find(params[:id]) || User.new
  end
end
