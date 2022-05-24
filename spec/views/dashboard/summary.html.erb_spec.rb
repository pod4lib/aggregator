# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'dashboard/summary', type: :view do
  let(:provider1) { create(:organization, name: 'provider1') }
  let(:job_tracker_active) { JobTracker.new(created_at: DateTime.now) }
  let(:job_tracker_attention) { JobTracker.new(created_at: DateTime.now) }
  let(:uploads1) do
    [
      create(:upload, :multiple_files, stream: provider1.default_stream),
      create(:upload, :multiple_files, stream: provider1.default_stream)
    ]
  end

  before do
    assign(:uploads, Kaminari.paginate_array(uploads1).page(1))
    assign(:recent_uploads_by_provider, { provider1 => uploads1 })
    allow(view).to receive(:files_status).and_return(:completed)
    # Add jobs to both status groups
    assign(:job_status_groups_by_provider,
           { provider1 => { active: [job_tracker_active], needs_attention: [job_tracker_attention] } })
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

  it 'renders the Upload activity table' do
    render

    expect(rendered).to have_css('table#upload-activity > tbody > tr > td', text: uploads1.first.name)
    expect(rendered).to have_css('table#upload-activity > tbody > tr > td', text: uploads1.first.files.first.filename.to_s)
  end

  it 'renders the Uploads pane' do
    render

    expect(rendered).to have_css('table#uploads-table > tbody > tr:first-child > td > a', text: provider1.name)
  end

  it 'renders the Jobs pane' do
    render

    expect(rendered).to have_css('table#jobs-table > tbody > tr > td > a', text: job_tracker_active.created_at)
    expect(rendered).to have_css('table#jobs-table > tbody > tr > td > a', text: job_tracker_attention.created_at)
  end
end
