# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'allowlisted_jwts/new', type: :view do
  let(:organization) { FactoryBot.create(:organization) }

  before do
    assign(:allowlisted_jwt, AllowlistedJwt.new)
    assign(:organization, organization)
  end

  it 'renders new upload form' do
    render
    assert_select 'form[action=?][method=?]', organization_allowlisted_jwts_path(organization), 'post' do
      assert_select 'input[name=?]', 'allowlisted_jwt[label]'
    end
  end

  it 'has options for different token scopes' do
    render
    assert_select 'form[action=?][method=?]', organization_allowlisted_jwts_path(organization), 'post' do
      assert_select 'input[name=?][value=?]', 'allowlisted_jwt[scope]', 'download'
      assert_select 'input[name=?][value=?]', 'allowlisted_jwt[scope]', 'upload'
    end
  end
end
