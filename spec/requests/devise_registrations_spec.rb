# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/users', type: :request do
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  describe 'PUT /update' do
    it 'allows name and title to be submitted' do
      put user_registration_path, params: { user: { name: 'Jane Doe', title: 'Adminstrator', current_password: user.password } }

      user.reload
      expect(user.name).to eq 'Jane Doe'
      expect(user.title).to eq 'Adminstrator'
    end
  end
end
