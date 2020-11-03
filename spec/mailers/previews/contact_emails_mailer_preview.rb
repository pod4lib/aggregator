# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/contact_emails_mailer
class ContactEmailsMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/contact_emails_mailer/confirm_email
  def confirm_email
    ContactEmailsMailer.confirm_email
  end
end
