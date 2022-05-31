# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateFullDumpJob, type: :job do
  let(:organization) { create(:organization) }

  before do
    organization.default_stream.uploads << build(:upload, :binary_marc)
    organization.default_stream.uploads << build(:upload, :long_file)
    organization.default_stream.uploads << build(:upload, :binary_marc)
  end

  it 'runs the ExtractMarcRecordMetadataJob for each upload if needed' do
    expect do
      described_class.perform_now(organization)
    end.to change(MarcRecord, :count).from(0).to(3)
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

    download_and_uncompress(organization.default_stream.normalized_dumps.last.marcxml) do |file|
      expect(Nokogiri::XML(file).xpath('//marc:record', marc: 'http://www.loc.gov/MARC21/slim').count).to eq 2
      expect(file.rewind && file.read).to include '</collection>'
    end
  end

  it 'does not contain any deleted MARC records from the organization' do
    organization.default_stream.uploads << build(:upload, :deletes)
    described_class.perform_now(organization)

    download_and_uncompress(organization.default_stream.normalized_dumps.last.marcxml) do |file|
      expect(Nokogiri::XML(file).xpath('//marc:record', marc: 'http://www.loc.gov/MARC21/slim').count).to eq 1
    end
  end

  # rubocop:disable Rspec/ExampleLength
  it 'does not generate empty OAI-XML files for uploads consisting of only deletes' do
    organization.default_stream.uploads << build(:upload, :deletes)
    allow(Settings).to receive(:oai_max_page_size).and_return(1)
    described_class.perform_now(organization)

    organization.default_stream.normalized_dumps.last.oai_xml.each do |file|
      expect(file.blob.byte_size.positive?).to be true
    end
  end
  # rubocop:enable Rspec/ExampleLength

  it 'has a content type of application/gzip for compressed marcxml' do
    described_class.perform_now(organization)

    expect(organization.default_stream.normalized_dumps.last.marcxml.attachment.blob.content_type).to eq 'application/gzip'
  end

  it 'has a filename of marcxml.xml.gz for compressed marcxml' do
    described_class.perform_now(organization)

    expect(organization.default_stream.normalized_dumps.last.marcxml.attachment.blob.filename.to_s).to match(/marcxml.xml.gz/)
  end

  it 'has a content type of application/gzip for compressed marc21' do
    described_class.perform_now(organization)

    expect(organization.default_stream.normalized_dumps.last.marc21.attachment.blob.content_type).to eq 'application/gzip'
  end

  it 'has a filename of marc21.mrc.gz for compressed marc21' do
    described_class.perform_now(organization)

    expect(organization.default_stream.normalized_dumps.last.marc21.attachment.blob.filename.to_s).to match(/marc21.mrc.gz/)
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
