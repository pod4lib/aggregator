# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarcAnalyzer do
  it 'reads and uploads metadata count for marcxml' do
    upload = FactoryBot.create(:upload, :marc_xml)
    upload.files.blobs.first.analyze
    expect(upload.files.blobs.first.metadata).to include(type: 'marcxml', count: 1)
  end

  it 'returns an error if no records are found' do
    upload = FactoryBot.create(:upload, :alma_marc_xml_ish)
    upload.files.blobs.first.analyze
    expect(upload.files.blobs.first.metadata).to include(valid: false, count: 0, error: 'No MARC records found')
  end

  it 'reads and uploads metadata count for binary marc' do
    upload = FactoryBot.create(:upload, :binary_marc)
    upload.files.blobs.first.analyze
    expect(upload.files.blobs.first.metadata).to include(type: 'marc21', count: 1)
  end
end
