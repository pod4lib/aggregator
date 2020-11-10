# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarcAnalyzer do
  it 'reads and uploads metadata count for marcxml' do
    upload = FactoryBot.create(:upload, :marc_xml)
    upload.files.blobs.first.analyze
    expect(upload.files.blobs.first.metadata).to include(type: 'marcxml', count: 1)
  end

  it 'reads and uploads metadata count for binary marc' do
    upload = FactoryBot.create(:upload, :binary_marc)
    upload.files.blobs.first.analyze
    expect(upload.files.blobs.first.metadata).to include(type: 'marc21', count: 1)
  end
end
