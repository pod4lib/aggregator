# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'routes for OrganizationUsersController' do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/organizations/1/users').to route_to(
        'organization_users#index', organization_id: '1'
      )
    end

    it 'routes to #destroy' do
      expect(delete: '/organizations/1/users/2').to route_to(
        'organization_users#destroy', organization_id: '1', id: '2'
      )
    end
  end
end
