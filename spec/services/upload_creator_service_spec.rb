# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadCreatorService do
  subject(:service) { described_class.call(upload) }

  let(:upload) { build(:upload, :binary_marc_gz) }

  context 'with an uploaded file' do
    it 'enqueues a job to extract metadata' do
      expect { service }.to enqueue_job(ExtractMarcRecordMetadataJob).exactly(1).times.with(upload)
    end

    it 'enqueues a job to extract files' do
      expect { service }.to enqueue_job(ExtractFilesJob).exactly(1).times.with(upload)
    end
  end

  context 'with a remote file' do
    let(:upload) { build(:upload, files: [], url: 'http://example.com/12345.marc') }

    it 'enqueues a job to attach the remote file' do
      expect { service }.to enqueue_job(AttachRemoteFileToUploadJob).exactly(1).times.with(upload)
    end

    it 'enqueues a job to extract metadata' do
      expect { service }.to enqueue_job(ExtractMarcRecordMetadataJob).exactly(1).times.with(upload)
    end

    it 'enqueues a job to extract files' do
      expect { service }.to enqueue_job(ExtractFilesJob).exactly(1).times.with(upload)
    end
  end
end
