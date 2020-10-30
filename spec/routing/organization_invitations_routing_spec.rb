# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationInvitationsController, type: :routing do
  describe 'routing' do
    it 'routes to #new' do
      expect(get: '/organizations/1/invite/new').to route_to('organization_invitations#new', organization_id: '1')
    end

    it 'routes to #create' do
      expect(post: '/organizations/1/invite').to route_to('organization_invitations#create', organization_id: '1')
    end
  end
end
