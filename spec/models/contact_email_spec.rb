# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactEmail, type: :model do
  subject(:contact_email) { build(:contact_email, organization: organization) }

  let(:organization) { build(:organization) }

  describe 'changing the email' do
    before do
      contact_email.confirm!
    end

    let!(:old_token) { contact_email.confirmation_token }

    it 'resets the confirmation' do
      contact_email.update(email: 'someone@example.com')
      expect(contact_email.confirmation_token).not_to eq old_token
      expect(contact_email).to have_attributes(confirmed_at: nil, confirmation_sent_at: nil)
    end
  end

  it 'sends a confirmation email' do
    expect do
      contact_email.save
    end.to have_enqueued_mail(ContactEmailsMailer, :confirm_email)
  end

  describe '#confirm!' do
    before { contact_email.save }

    it 'adds a confirmed_at value' do
      contact_email.confirm!

      expect(contact_email.confirmed_at).to be_present
    end
  end
end
