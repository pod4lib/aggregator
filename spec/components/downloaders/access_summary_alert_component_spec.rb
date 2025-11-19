# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Downloaders::AccessSummaryAlertComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new(organization: organization)).to_html)
  end

  let(:organization) { create(:organization, name: 'Test Org') }

  context 'when downloads are unrestricted' do
    before do
      organization.update(restrict_downloads: false)
    end

    it 'displays unrestricted access message' do
      expect(rendered.text).to include('Test Org is currently unrestricted. Any POD organization can access its data')
    end
  end

  context 'when downloads are restricted to specific groups and organizations' do
    before do
      organization.update(restrict_downloads: true)
      Downloader.create!(organization: organization, resource: create(:group))
      Downloader.create!(organization: organization, resource: create(:organization))
    end

    it 'displays restricted group and org access message' do
      expect(rendered.text).to include('Test Org has restrictions set, allowing access to specific organizations and groups.')
    end
  end

  context 'when downloads are restricted to specific groups only' do
    before do
      organization.update(restrict_downloads: true)
      Downloader.create!(organization: organization, resource: create(:group))
    end

    it 'displays restricted group access message' do
      expect(rendered.text).to include('Test Org has restrictions set, allowing access to specific groups.')
    end
  end

  context 'when downloads are restricted to specific organizations only' do
    before do
      organization.update(restrict_downloads: true)
      Downloader.create!(organization: organization, resource: create(:organization))
    end

    it 'displays restricted org access message' do
      expect(rendered.text).to include('Test Org has restrictions set, allowing access to specific organizations.')
    end
  end

  context 'when no access is granted' do
    before do
      organization.update(restrict_downloads: true)
    end

    it 'displays no access message' do
      expect(rendered.text).to include('Test Org has restrictions set and has not granted access to any organizations or groups.')
    end
  end
end
