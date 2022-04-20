# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_organization_header', type: :view do
  let(:organization) do
    create(:organization,
           name: 'Best University',
           code: 'Bst')
  end
  let(:stream) { create(:stream_with_uploads, organization: organization) }
  let(:user) { create(:user) }
  let(:contact_email) { create(:contact_email, organization: organization) }

  before do
    assign(:organization, organization)
    assign(:stream, stream)
    assign(:contact_email, contact_email)
  end

  it 'displays the organization name' do
    render

    expect(view.content_for(:org_header)).to include(organization.name)
  end

  it 'displays the organization code' do
    render

    expect(view.content_for(:org_header)).to include(organization.code)
  end

  it 'displays the organization contact email' do
    render

    expect(view.content_for(:org_header)).to include(contact_email.email)
  end

  it 'links to Manage organization on certain pages with privileged user' do
    allow(view).to receive(:can?).and_return(true)
    allow(view).to receive(:current_page?).and_return(true)
    render

    expect(view.content_for(:org_header)).to have_link 'Manage organization'
  end

  it 'links to View organization on certain pages with unprivileged user' do
    allow(view).to receive(:current_page?).and_return(true)
    render

    expect(view.content_for(:org_header)).to have_link 'View organization'
  end

  it 'otherwise links to Default stream for provider orgs' do
    render

    expect(view.content_for(:org_header)).to have_link 'Default stream'
  end
end
