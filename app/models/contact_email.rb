# frozen_string_literal: true

# Contact emails for an organization
class ContactEmail < ApplicationRecord
  belongs_to :organization
  has_secure_token :confirmation_token

  before_validation if: :email_changed? do
    self.confirmation_token = self.class.generate_unique_secure_token
    self.confirmed_at = nil
    self.confirmation_sent_at = nil
  end

  after_commit do
    ContactEmailsMailer.with(contact_email: self).confirm_email.deliver_later if confirmation_sent_at.blank?
  end

  def confirm!
    update!(confirmed_at: Time.zone.now)
  end
end
