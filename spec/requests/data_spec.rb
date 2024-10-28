# frozen_string_literal: true

require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe '/data' do
  describe 'GET /data' do
    it 'does not render a successful response when not logged in' do
      get data_url
      expect(response).not_to be_successful
      # redirect to login
      expect(response).to have_http_status(:see_other)
    end

    it 'renders a successful response when logged in' do
      sign_in create(:admin)
      get data_url
      expect(response).to be_successful
    end
  end
end
