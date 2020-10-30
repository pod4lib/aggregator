# frozen_string_literal: true

# Customize devise_invitable's controller with support for inviting a new
# or existing user to an organization
class OrganizationInvitationsController < Devise::InvitationsController
  load_and_authorize_resource :organization, only: %i[new create]

  def new
    authorize! :invite, @organization
    super
  end

  def create
    authorize! :invite, @organization
    super
  end

  def after_invite_path_for(*_args)
    @organization
  end

  def devise_mapping
    Devise.mappings[:user]
  end

  def invite_resource(*args)
    if User.where(email: invite_params[:email]).none?
      super do |user|
        user.add_role(:member, @organization)
      end
    else
      user = User.find_by(email: invite_params[:email])
      user.add_role(:member, @organization)
      user
    end
  end
end
