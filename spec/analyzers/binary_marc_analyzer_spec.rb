# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BinaryMarcAnalyzer do
  it 'reads and uploads metadata count for binary marc' do
    upload = FactoryBot.create(:upload, :binary_marc)
    upload.files.blobs.first.analyze
    expect(upload.files.blobs.first.metadata).to include count: 1
  end
end
