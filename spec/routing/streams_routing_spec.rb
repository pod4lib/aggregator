# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StreamsController, type: :routing do
  describe 'routing' do
    it 'routes to #normalized_data' do
      expect(get: '/organizations/1/streams/2/normalized_data').to route_to('streams#normalized_data', id: '2',
                                                                                                       organization_id: '1')
    end

    it 'routes to #processing_status' do
      expect(get: '/organizations/1/streams/2/processing_status').to route_to('streams#processing_status', id: '2',
                                                                                                           organization_id: '1')
    end
  end
end
