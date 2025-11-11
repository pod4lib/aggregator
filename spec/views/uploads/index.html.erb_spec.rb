# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'uploads/index' do
  let(:organization) { create(:organization) }
  let(:stream) { create(:stream, organization: organization) }

  before do
    assign(:organization, organization)
    assign(:stream, stream)
    Upload.create!([
                     {
                       name: 'One',
                       files: [fixture_file_upload(Rails.root.join('spec/fixtures/1297245.marc'), 'application/octet-stream')],
                       stream: stream
                     },
                     {
                       name: 'Two',
                       files: [fixture_file_upload(Rails.root.join('spec/fixtures/1297245.marc'), 'application/octet-stream')],
                       stream: stream
                     }
                   ])
    assign(:uploads, stream.uploads.page(params[:page]))
    allow(view).to receive(:can?).and_return(true)
  end

  it 'renders a list of uploads with links to their files' do
    render

    expect(rendered).to have_css('tr>td>a', text: '1297245.marc', count: 2)
  end

  it 'shows Delete button to privileged users' do
    allow(view).to receive(:can?).and_return(true)
    render

    assert_select 'a', text: 'Delete'
  end
end
