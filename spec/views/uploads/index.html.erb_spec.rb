# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'uploads/index', type: :view do
  let(:organization) { create(:organization) }
  let(:stream) { create(:stream, organization: organization) }

  before do
    assign(:uploads, [
             Upload.create!(
               name: 'One',
               files: [fixture_file_upload(Rails.root.join('spec/fixtures/1297245.marc'), 'application/octet-stream')],
               stream: stream
             ),
             Upload.create!(
               name: 'Two',
               files: [fixture_file_upload(Rails.root.join('spec/fixtures/1297245.marc'), 'application/octet-stream')],
               stream: stream
             )
           ])
    assign(:organization, organization)
    assign(:stream, stream)
  end

  it 'renders a list of uploads with links to their show pages' do
    render

    expect(rendered).to have_css('tr>td>a', text: 'One', count: 1)
    expect(rendered).to have_css('tr>td>a', text: 'Two', count: 1)
  end

  it 'links to the stream associated with each upload' do
    render

    expect(rendered).to have_css('tr>td>a', text: stream.name, count: 2)
  end

  it 'shows Delete button to privileged users' do
    allow(view).to receive(:can?).and_return(true)
    render

    assert_select 'a.btn', text: 'Delete'
  end
end
