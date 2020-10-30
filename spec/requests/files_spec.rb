# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/files', type: :request do
  before do
    sign_in FactoryBot.create(:admin)
  end

  describe 'GET /files/' do
    let(:upload) { FactoryBot.create(:upload, :binary_marc) }

    context 'when non-range requests' do
      let(:expected_headers) do
        {
          'Accept-Ranges' => 'bytes',
          'Content-Disposition' => 'attachment',
          'Content-Type' => 'application/octet-stream',
          'Etag' => 'W/"6f9974da7d9740e8341d81ba1d4d7d90"'
        }
      end

      before do
        get download_url(upload.files.first)
      end

      it 'renders a successful response' do
        expect(response).to be_successful
      end

      it 'sets headers' do
        expected_headers.each do |k, v|
          expect(response.headers[k]).to eq v
        end
      end

      it 'is streamed' do
        expect(response.stream.body.present?).to be true
      end
    end

    context 'when range requests' do
      let(:expected_headers) do
        {
          'Accept-Ranges' => 'bytes',
          'Content-Disposition' => 'attachment',
          'Content-Type' => 'application/octet-stream',
          'Content-Range' => 'bytes 0-3/1407'
        }
      end

      before do
        get(download_url(upload.files.first), headers: { 'Range' => 'bytes=0-3,-2' })
      end

      it 'renders a successful response' do
        expect(response).to be_successful
      end

      it 'sets headers' do
        expected_headers.each do |k, v|
          expect(response.headers[k]).to eq v
        end
      end

      it 'is streamed' do
        expect(response.stream.body.present?).to be true
      end
    end
  end
end
