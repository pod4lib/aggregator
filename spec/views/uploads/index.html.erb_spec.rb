# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'uploads/index', type: :view do
  let(:organization) { FactoryBot.create(:organization) }

  before do
    assign(:uploads, [
             Upload.create!(
               name: 'Name',
               files: [fixture_file_upload(Rails.root.join('spec/fixtures/1297245.marc'), 'application/octet-stream')],
               stream_id: organization.default_stream.id
             ),
             Upload.create!(
               name: 'Name',
               files: [fixture_file_upload(Rails.root.join('spec/fixtures/1297245.marc'), 'application/octet-stream')],
               stream_id: organization.default_stream.id
             )
           ])
    assign(:organization, organization)
  end

  it 'renders a list of uploads' do
    render
    expect(rendered).to have_css('tr>td', text: 'Name', count: 2)
  end
end
