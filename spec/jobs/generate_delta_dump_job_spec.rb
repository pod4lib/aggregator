# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateDeltaDumpJob do
  let(:organization) { create(:organization) }

  before do
    Timecop.travel(5.days.ago)
    organization.default_stream.uploads << build(:upload, :binary_marc)
    organization.default_stream.uploads << build(:upload, :binary_marc)
    GenerateFullDumpJob.perform_now(organization)

    Timecop.return
    organization.default_stream.uploads << build(:upload, :binary_marc)
  end

  it 'runs the ExtractMarcRecordMetadataJob for each upload if needed' do
    expect do
      described_class.perform_now(organization)
    end.to change(MarcRecord, :count).from(2).to(3)
  end

  it 'creates a new normalized delta dump' do
    expect do
      described_class.perform_now(organization)
    end.to change { organization.default_stream.reload.current_full_dump.deltas.count }.by(1)
  end

  it 'contains just the new the MARC records from the organization' do
    described_class.perform_now(organization)

    download_and_uncompress(organization.default_stream.reload.current_full_dump.deltas.last.marcxml) do |file|
      expect(Nokogiri::XML(file).xpath('//marc:record', marc: 'http://www.loc.gov/MARC21/slim').count).to eq 1
      expect(file.rewind && file.read).to include '</collection>'
    end
  end

  it 'has a content type of application/gzip for compressed marcxml' do
    described_class.perform_now(organization)

    expect(organization.default_stream.reload.current_full_dump.deltas.last
                       .marcxml.attachment.blob.content_type).to eq 'application/gzip'
  end

  it 'has a filename of marcxml.xml.gz for compressed marcxml' do
    described_class.perform_now(organization)

    expect(organization.default_stream.reload.current_full_dump.deltas.last
                       .marcxml.attachment.blob.filename.to_s).to end_with 'marcxml.xml.gz'
  end

  it 'has a content type of application/gzip for compressed marc21' do
    described_class.perform_now(organization)

    expect(organization.default_stream.reload.current_full_dump.deltas.last
                       .marc21.attachment.blob.content_type).to eq 'application/gzip'
  end

  it 'has a filename of marc21.mrc.gz for compressed marc21' do
    described_class.perform_now(organization)

    expect(organization.default_stream.reload.current_full_dump.deltas.last
                       .marc21.attachment.blob.filename.to_s).to end_with 'marc21.mrc.gz'
  end

  context 'with deletes' do
    before do
      organization.default_stream.uploads << build(:upload, :deletes)
      organization.default_stream.uploads << build(:upload, :deletes)
    end

    it 'collects deletes into a single file' do
      described_class.perform_now(organization)
      organization.default_stream.reload.current_full_dump.deltas.last.deletes.download do |file|
        expect(file.each_line.count).to eq 4
      end
    end

    it 'has a content type of text/plain for deletes' do
      described_class.perform_now(organization)

      expect(organization.default_stream.reload.current_full_dump.deltas.last
                         .deletes.attachment.blob.content_type).to eq 'text/plain'
    end

    it 'has a filename of deletes.del.txt for deletes' do
      described_class.perform_now(organization)

      expect(organization.default_stream.reload.current_full_dump.deltas.last
                         .deletes.attachment.blob.filename.to_s).to end_with 'deletes.del.txt'
    end

    it 'does not include MARC records that were deleted' do
      described_class.perform_now(organization)

      expect(organization.default_stream.reload.current_full_dump.deltas.last.marcxml.attachment).to be_nil
    end

    it 'does not include deletes that were readded' do
      organization.default_stream.uploads << build(:upload, :binary_marc)
      described_class.perform_now(organization)

      organization.default_stream.reload.current_full_dump.deltas.last.deletes.download do |file|
        expect(file).not_to include 'a1297245'
      end
    end

    it 'includes MARC records that were re-added' do
      organization.default_stream.uploads << build(:upload, :binary_marc)
      described_class.perform_now(organization)

      download_and_uncompress(organization.default_stream.reload.current_full_dump.deltas.last.marcxml) do |file|
        expect(Nokogiri::XML(file).xpath('//marc:record', marc: 'http://www.loc.gov/MARC21/slim').count).to eq 1
      end
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
    attachment.download do |content|
      yield Zlib::GzipReader.new(StringIO.new(content))
    end
  end
end
