# frozen_string_literal: true

# Inject recaptch validation into the devise registration cycle
class RegistrationsController < Devise::RegistrationsController
  include RecaptchaConcern

  # provided by devise:
  # rubocop:disable Rails/LexicallyScopedActionFilter
  prepend_before_action :check_captcha, only: [:create] # Change this to be any actions you want to protect.
  # rubocop:enable Rails/LexicallyScopedActionFilter

  private

  def check_captcha
    return if verify_recaptcha?(params.dig(:recaptcha_token, 0), action: 'register')

    flash.now[:error] = 'Unable to verify recaptcha; contact... someone... for further assistance'
    self.resource = resource_class.new sign_up_params
    resource.validate # Look for any other validation errors besides reCAPTCHA
    set_minimum_password_length
    respond_with_navigational(resource) { render :new }
  end
end
