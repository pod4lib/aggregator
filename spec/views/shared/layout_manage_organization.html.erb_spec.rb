# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_layout_manage_organization', type: :view do
  let(:is_provider) { true }
  let(:organization) do
    create(:organization, name: 'Best University', provider: is_provider)
  end
  let(:stream) { create(:stream_with_uploads, organization: organization) }
  let(:user) { create(:user) }

  before do
    assign(:organization, organization)
    assign(:stream, stream)
  end

  it 'links to Default stream for provider orgs' do
    render

    expect(view.content_for(:org_header)).to have_link 'Default stream'
  end

  context 'with a consumer org' do
    let(:is_provider) { false }

    it 'does not link to Default stream for consumer orgs' do
      render

      expect(view.content_for(:org_header)).not_to have_link 'Default stream'
    end
  end
end
