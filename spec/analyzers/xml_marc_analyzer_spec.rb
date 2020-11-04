# frozen_string_literal: true

require 'rails_helper'

RSpec.describe XmlMarcAnalyzer do
  it 'reads and uploads metadata count for binary marc' do
    upload = FactoryBot.create(:upload, :marc_xml)
    upload.files.blobs.first.analyze
    expect(upload.files.blobs.first.metadata).to include(analyzer: 'XmlMarcAnalyzer', count: 1)
  end
end
