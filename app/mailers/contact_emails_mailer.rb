# frozen_string_literal: true

# :nodoc:
class ContactEmailsMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.contact_emails_mailer.confirm_email.subject
  #
  def confirm_email
    @contact_email = params[:contact_email]
    mail to: @contact_email.email
  end
end
