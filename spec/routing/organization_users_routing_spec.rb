# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationInvitationsController, type: :routing do
  describe 'routing' do
    it 'routes to #destroy' do
      expect(delete: '/organizations/1/organization_users/2').to route_to(
        'organization_users#destroy', organization_id: '1', id: '2'
      )
    end
  end
end
