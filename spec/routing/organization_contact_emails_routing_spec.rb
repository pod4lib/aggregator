# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationContactEmailsController, type: :routing do
  describe 'routing' do
    it 'routes to #new' do
      expect(get: '/organizations/1/organization_contact_emails/new').to route_to(
        controller: 'organization_contact_emails', action: 'new', organization_id: '1'
      )
    end

    it 'routes to #destroy' do
      expect(delete: '/organizations/1/organization_contact_emails/2').to route_to(
        controller: 'organization_contact_emails', action: 'destroy', organization_id: '1', id: '2'
      )
    end
  end
end
