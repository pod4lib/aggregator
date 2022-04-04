# frozen_string_literal: true

# Subclass of devise controller so we can control edit profile logic
class RegistrationsController < Devise::RegistrationsController
  protected

  def update_resource(resource, params)
    # Require current password if user is trying to change password.
    return super if params['password']&.present?

    # Allow user to update other registration info without password
    resource.update_without_password(params.except('current_password'))
  end
end
