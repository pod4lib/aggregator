# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'allowlisted_jwts/new' do
  let(:organization) { create(:organization) }

  before do
    assign(:allowlisted_jwt, AllowlistedJwt.new)
    assign(:organization, organization)
    render
  end

  it 'renders new upload form' do
    assert_select 'form[action=?][method=?]', organization_allowlisted_jwts_path(organization), 'post' do
      assert_select 'input[name=?]', 'allowlisted_jwt[label]'
    end
  end

  it 'has options for different token scopes' do
    assert_select 'form[action=?][method=?]', organization_allowlisted_jwts_path(organization), 'post' do
      assert_select 'input[name=?][value=?]', 'allowlisted_jwt[scope]', 'download'
      assert_select 'input[name=?][value=?]', 'allowlisted_jwt[scope]', 'upload'
      assert_select 'input[name=?][value=?]', 'allowlisted_jwt[scope]', 'all'
    end
  end

  context 'when organization is not a provider' do
    let(:organization) { create(:organization, :consumer) }

    it 'only has option for download-only token scope' do
      assert_select 'form[action=?][method=?]', organization_allowlisted_jwts_path(organization), 'post' do
        assert_select 'input[name=?][value=?]', 'allowlisted_jwt[scope]', 'download'
        assert_select 'input[name=?][value=?]', 'allowlisted_jwt[scope]', 'upload', count: 0
        assert_select 'input[name=?][value=?]', 'allowlisted_jwt[scope]', 'all', count: 0
      end
    end
  end
end
