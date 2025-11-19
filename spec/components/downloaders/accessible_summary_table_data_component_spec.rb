# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Downloaders::AccessibleSummaryTableDataComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new(organization: organization, other_org: other_org)).to_html)
  end

  let(:organization) { create(:organization, name: 'Test Org') }
  let(:other_org) { create(:organization, name: 'Other Org') }

  context 'when unrestricted access is allowed' do
    before do
      other_org.update(restrict_downloads: false)
    end

    it 'renders the unrestricted access explanation' do
      expect(rendered.text).to include('Other Org has no restrictions set')
      expect(rendered).to have_css('i', class: 'can_access')
    end
  end

  context 'when access is restricted and granted directly' do
    before do
      other_org.update(restrict_downloads: true)
      other_org.downloader_organizations << organization
    end

    it 'renders the direct access explanation' do
      expect(rendered.text).to include('Access granted directly to Test Org')
      expect(rendered).to have_css('i', class: 'can_access')
    end
  end

  context 'when access is restricted and granted via group membership' do
    let(:group) { create(:group, name: 'Test Group') }

    before do
      other_org.update(restrict_downloads: true)
      other_org.downloader_groups << group
      organization.groups << group
    end

    it 'renders the group membership access explanation' do
      expect(rendered.text).to include("Access granted to Test Org through its #{group.display_name} membership")
      expect(rendered).to have_css('i', class: 'can_access')
    end
  end
end
