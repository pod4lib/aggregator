# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Downloading normalzed files from POD', type: :feature do
  let(:organization) { FactoryBot.create(:organization, code: 'best-org') }
  let(:user) { FactoryBot.create(:user) }

  before do
    user.add_role :member, organization
    login_as(user, scope: :user)

    FactoryBot.create_list(:upload, 2, :binary_marc, organization: organization, stream: organization.default_stream)
    FactoryBot.create_list(:upload, 2, :binary_marc_gz, organization: organization, stream: organization.default_stream)
  end

  describe 'Full dumps' do
    before do
      allow(Time.zone).to receive(:today).and_return('2020-01-01')
      GenerateFullDumpJob.perform_now(organization)
    end

    it 'generates a deletes file and provides a link to it' do
      visit organization_url(organization)

      expect(page).to have_link 'deleted-records.txt'
    end

    it 'generates binary & xml full dump files and provides a link to them' do
      visit organization_url(organization)

      expect(page).to have_link "#{organization.slug}-2020-01-01-marc21.mrc.gz"
      expect(page).to have_link "#{organization.slug}-2020-01-01-marcxml.xml.gz"
    end

    it 'provides all MARC records that have been uploaded to the default stream gzipped into one dump file' do
      visit organization_url(organization)

      # Note, this won't work in a driver other that Rack::Test w/o some other magic
      click_link "#{organization.slug}-2020-01-01-marc21.mrc.gz"
      marc = MarcRecordService.marc_reader(StringIO.new(page.body), :marc21_gzip)

      expect(page.response_headers['Content-Disposition']).to eq 'attachment'
      expect(marc.each_raw.count).to eq 4
    end

    it 'provides augmented MARC records with POD and Organizational provenance' do
      visit organization_url(organization)

      # Note, this won't work in a driver other that Rack::Test w/o some other magic
      click_link "#{organization.slug}-2020-01-01-marc21.mrc.gz"
      records = MarcRecordService.marc_reader(StringIO.new(page.body), :marc21_gzip)

      records.each do |marc|
        expect(marc['900']['5']).to eq 'POD'
        expect(marc['900']['b']).to eq organization.code
      end
    end

    it 'tracks the download' do
      visit organization_url(organization)

      expect do
        # Note, this won't work in a driver other that Rack::Test w/o some other magic
        click_link "#{organization.slug}-2020-01-01-marc21.mrc.gz"
      end.to change(Ahoy::Event, :count).by(1)

      expect(Ahoy::Event.last.properties.with_indifferent_access).to include(
        attachment_name: 'full_dump_binary',
        byte_size: 891,
        filename: "#{organization.slug}-2020-01-01-marc21.mrc.gz",
        organization_id: organization.slug
      )

      expect(Ahoy::Event.last.visit).to have_attributes(
        organization_id: organization.slug
      )
    end
  end
end
