# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExtractMarcRecordMetadataJob, type: :job do
  let(:upload) { FactoryBot.create(:upload, :binary_marc) }

  it 'extract MarcRecord instances from data from each file' do
    expect do
      described_class.perform_now(upload)
    end.to change(MarcRecord, :count).by(1)

    expect(MarcRecord.last).to have_attributes marc001: 'a1297245', bytecount: 0, length: 1407, index: 0
  end
end
