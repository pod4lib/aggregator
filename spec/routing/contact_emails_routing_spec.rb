# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'routes for ContactEmailsController' do
  describe 'routing' do
    it 'routes to #confirm' do
      expect(get: '/contact_emails/confirm/abcdef').to route_to(
        controller: 'contact_emails', action: 'confirm', token: 'abcdef'
      )
    end
  end
end
