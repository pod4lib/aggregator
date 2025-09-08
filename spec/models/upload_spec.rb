# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Upload do
  subject(:upload) { create(:upload, :binary_marc) }

  describe 'validations' do
    it 'validates that a URL or files are present' do
      expect do
        create(:upload, files: [])
      end.to raise_error(ActiveRecord::RecordInvalid,
                         "Validation failed: Url A URL must be provided if a file has not been uploaded, Files can't be blank")
    end

    context 'with an invalid URL' do
      before { upload.update(url: 'not-a-good.url') }

      it { expect(upload).not_to be_valid }
      it { expect(upload.errors[:url]).to include 'Unable to attach file from URL' }
    end
  end

  describe '#name' do
    it 'has a default name' do
      expect(upload.name).to match(/^\d{4}-\d{2}-\d{2}/)
    end
  end

  describe '#archive' do
    it 'sets status to archived' do
      upload.archive
      expect(upload.status).to eq 'archived'
    end

    it 'enqueues purge_later for every file' do
      expect do
        upload.archive
      end.to have_enqueued_job(ActiveStorage::PurgeJob)
    end
  end

  describe '#read_marc_record_metadata' do
    subject(:upload) { create(:upload, :small_batch_gz) }

    it 'uses the same object for the upload' do
      first, second = upload.read_marc_record_metadata.first(2).map(&:upload)

      expect(first.object_id).to eq second.object_id
    end
  end
end
