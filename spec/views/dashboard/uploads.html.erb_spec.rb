# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'dashboard/uploads', type: :view do
  let(:organization) { create(:organization) }
  let(:stream) { create(:stream, organization: organization) }
  let(:uploads) do
    [
      create(:upload, :binary_marc, stream: stream),
      create(:upload, :marc_xml, stream: stream),
      create(:upload, :multple_files, stream: stream)
    ]
  end

  before do
    assign(:uploads, Kaminari.paginate_array(uploads).page(1))
  end

  it 'renders a list of uploads' do
    render
    expect(rendered).to have_css('tbody > tr', count: 7)
    expect(rendered).to have_css('tbody > tr:first-child > td', text: organization.name)
      .and have_css('tbody > tr:first-child > td', text: uploads.first.name)
      .and have_css('tbody > tr:nth-child(2) > td', text: uploads.first.files.first.filename)
  end
end
