# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PagesController, type: :routing do
  describe 'routing' do
    it 'routes to #home' do
      expect(get: '/').to route_to('pages#home')
    end

    it 'routes to #api' do
      expect(get: '/api').to route_to('pages#api')
    end
  end
end
