# frozen_string_literal: true

require 'rails_helper'
# require 'active_storage_attachment_metadata_status'

RSpec.describe DashboardHelper, type: :helper do
  let(:organization) { create(:organization) }
  let(:stream) { create(:stream, organization: organization) }
  let(:uploads) do
    [
      create(:upload, :binary_marc, stream: stream),
      create(:upload, :multiple_files, stream: stream),
      create(:upload, :binary_marc, stream: stream)
    ]
  end

  before do
    # Create successful upload metadata for uploads[0]
    uploads[0].files.first.metadata = { 'identified' => true, 'analyzer' => 'MarcAnalyzer', 'count' => 1, 'type' => 'marc21',
                                        'analyzed' => true }

    # Create mixed success/fail upload metadata for uploads[1]
    uploads[1].files[0].metadata = { 'identified' => true, 'analyzer' => 'MarcAnalyzer', 'count' => 1, 'type' => 'marc21',
                                     'analyzed' => true }
    uploads[1].files[1].metadata = { 'identified' => true, 'analyzer' => 'fake', 'count' => 1, 'analyzed' => true }
  end

  describe '#files_status' do
    it 'returns completed status for valid uploads' do
      expect(helper.files_status(uploads[0])).to eq('completed')
    end

    it 'returns needs_attention status for mixed uploads' do
      expect(helper.files_status(uploads[1])).to eq('needs_attention')
    end

    it 'returns failed status for bad uploads' do
      # we didn't set any metadata for uploads[2] so it defaults to fail
      expect(helper.files_status(uploads[2])).to eq('failed')
    end
  end

  describe '#best_status' do
    it 'returns the best status out of a group from a given upload' do
      expect(helper.best_status(uploads)).to eq('completed')
    end
  end

  describe '#last_successful_upload_date' do
    it 'returns the date of the most recent successful upload' do
      expect(helper.last_successful_upload_date(uploads)).to eq(uploads[0].created_at)
    end
  end
end
