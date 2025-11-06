# frozen_string_literal: true

# Controller for site admin actions like becoming a superuser
class SiteAdminController < ApplicationController
  before_action :authenticate_user!
  skip_authorization_check only: %i[become_superadmin disclaim_superadmin]

  def become_superadmin
    authorize! :become, :superadmin

    cookies[:acting_as_superadmin] = { value: 'true', expires: 1.hour.from_now }

    redirect_back fallback_location: root_path, notice: t('site_admin.became_superadmin')
  end

  def disclaim_superadmin
    authorize! :become, :superadmin

    cookies.delete(:acting_as_superadmin)

    redirect_back fallback_location: root_path, notice: t('site_admin.disclaimed_superadmin')
  end
end
