# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_organization_header' do
  let(:organization) do
    create(:organization,
           name: 'Best University',
           code: 'Bst',
           groups: [group])
  end
  let(:group) { create(:group, short_name: 'Group') }
  let(:stream) { create(:stream_with_uploads, organization: organization) }
  let(:user) { create(:user) }
  let(:contact_email) { create(:contact_email, organization: organization) }

  before do
    assign(:organization, organization)
    assign(:stream, stream)
    assign(:contact_email, contact_email)
    render
  end

  it 'displays the organization name' do
    expect(view.content_for(:org_header)).to include(organization.name)
  end

  it 'displays the organization code' do
    expect(view.content_for(:org_header)).to include(organization.code)
  end

  it 'displays the organization contact email' do
    expect(view.content_for(:org_header)).to include(contact_email.email)
  end

  it 'displays the group short name' do
    expect(view.content_for(:org_header)).to include(group.short_name)
  end

  it 'does not display the consumer-only badge' do
    expect(view.content_for(:org_header)).not_to include('Consumer-only')
  end

  context 'when the organization is consumer-only' do
    let(:organization) do
      create(:organization, :consumer)
    end

    it 'displays the consumer-only badge' do
      expect(view.content_for(:org_header)).to include('Consumer-only')
    end
  end
end
