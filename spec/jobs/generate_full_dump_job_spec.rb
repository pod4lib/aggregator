# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateFullDumpJob, type: :job do
  let(:organization) { FactoryBot.create(:organization) }

  before do
    organization.default_stream.uploads << FactoryBot.build(:upload, :binary_marc)
    organization.default_stream.uploads << FactoryBot.build(:upload, :binary_marc)
    organization.default_stream.uploads << FactoryBot.build(:upload, :binary_marc)
  end

  it 'creates a new normalized dump' do
    expect do
      described_class.perform_now(organization)
    end.to change(NormalizedDump, :count).by(1)

    expect(NormalizedDump.last).to have_attributes stream_id: organization.default_stream.id
  end

  it 'kicks off a delta dump' do
    expect do
      described_class.perform_now(organization)
    end.to enqueue_job GenerateDeltaDumpJob
  end

  it 'contains all the MARC records from the organization' do
    described_class.perform_now(organization)

    download_and_uncompress(organization.default_stream.normalized_dumps.last.full_dump_xml) do |file|
      expect(Nokogiri::XML(file).xpath('//marc:record', marc: 'http://www.loc.gov/MARC21/slim').count).to eq 3
      expect(file.rewind && file.read).to include '</collection>'
    end
  end

  describe '.enqueue_all' do
    it 'enqueues jobs for each organization' do
      expect do
        described_class.enqueue_all
      end.to enqueue_job(described_class).exactly(Organization.count).times
    end
  end

  def download_and_uncompress(attachment)
    expect(attachment).to be_attached

    attachment.download do |content|
      yield Zlib::GzipReader.new(StringIO.new(content))
    end
  end
end
