# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'dashboard/uploads', type: :view do
  let(:organization) { create(:organization) }
  let(:stream) { create(:stream, organization: organization) }
  let(:uploads) do
    [
      create(:upload, :multiple_files, stream: stream)
    ]
  end

  let(:org2) { create(:organization) }
  let(:stream2) { create(:stream, organization: org2) }
  let(:uploads2) do
    [
      create(:upload, :multiple_files, stream: stream2)
    ]
  end

  before do
    assign(:uploads, Kaminari.paginate_array(uploads).page(1))
    assign(:recent_uploads_by_provider, { organization: uploads, org2: uploads2 })
    allow(view).to receive(:files_status).and_return('completed')
  end

  it 'renders a list of all uploads' do
    render

    expect(rendered).to have_css('tbody > tr', count: 4)
    expect(rendered).to have_css('tbody > tr:first-child > td', text: organization.name)
      .and have_css('tbody > tr:first-child > td', text: uploads.first.name)
      .and have_css('tbody > tr:first-child > td', text: uploads.first.files.first.filename)
  end

  # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
  it 'renders the tab layout' do
    render

    expect(rendered).to have_css('ul#summary-tabs > li', count: 5)
    expect(rendered).to have_css('div#summary-tabs-content > div#uploads-pane', count: 1)
    expect(rendered).to have_css('div#summary-tabs-content > div#job-status-pane', count: 1)
    expect(rendered).to have_css('div#summary-tabs-content > div#normalized-data-pane', count: 1)
    expect(rendered).to have_css('div#summary-tabs-content > div#files-pane', count: 1)
    expect(rendered).to have_css('div#summary-tabs-content > div#users-pane', count: 1)
  end
  # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
end
