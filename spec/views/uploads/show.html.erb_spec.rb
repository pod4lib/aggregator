# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'uploads/show', type: :view do
  let(:organization) { FactoryBot.create(:organization) }

  before do
    assign(:upload, Upload.create!(
                      name: 'Name',
                      files: [fixture_file_upload(Rails.root.join('spec/fixtures/1297245.marc'), 'application/octet-stream')],
                      stream_id: organization.default_stream.id
                    ))
    assign(:organization, organization)
  end

  it 'renders attributes' do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/1297245.marc/)
  end
end
