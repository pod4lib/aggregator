# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReanalyzeJob, type: :job do
  let(:organization) { create(:organization) }

  context 'with a stream' do
    let(:stream) { organization.default_stream }

    before do
      stream.uploads << build(:upload, :binary_marc)
      stream.uploads << build(:upload, :binary_marc)
      stream.uploads << build(:upload, :binary_marc)
    end

    it 'enqueues reanalyzing uploads' do
      expect { described_class.perform_now(stream) }.to enqueue_job(described_class).exactly(3).times
    end
  end

  context 'with an upload' do
    let(:upload) { create(:upload, :binary_marc) }

    it 'enqueues extracting the marc records' do
      expect { described_class.perform_now(upload) }.to enqueue_job(ExtractMarcRecordMetadataJob).once.with(upload)
    end

    it 'enqueues reanalyzing the files' do
      expect { described_class.perform_now(upload) }.to enqueue_job(described_class).once.with(upload.files.first.blob)
    end
  end

  context 'with a file' do
    let(:upload) { create(:upload, :binary_marc) }
    let(:file) { upload.files.first.blob }

    it 'enqueues reanalyzing the file' do
      allow(file).to receive(:analyze_later)
      described_class.perform_now(file)
      expect(file).to have_received(:analyze_later)
    end
  end
end
