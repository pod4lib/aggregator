# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'dashboard/summary' do
  let(:dashboard) { Dashboard.new }
  let(:provider1) { create(:organization, name: 'provider1') }
  let(:uploads1) do
    create_list(:upload, 2, :multiple_files, stream: provider1.default_stream)
  end
  let(:job_tracker_active) { JobTracker.new(created_at: DateTime.now) }
  let(:job_tracker_attention) { JobTracker.new(created_at: DateTime.now) }
  let(:normalized_data) { create(:normalized_dump, stream_id: provider1.default_stream.id) }

  before do
    assign(:uploads, Kaminari.paginate_array(uploads1).page(1))
    assign(:dashboard, dashboard)

    allow(view).to receive_messages(files_status: :completed, count_roles: { admin: 1, owner: 2, member: 3 })

    allow(dashboard).to receive_messages(recent_uploads_by_provider: { provider1 => uploads1 },
                                         job_status_groups_by_provider: { provider1 => { active: [job_tracker_active],
                                                                                         needs_attention: [job_tracker_attention] } },
                                         normalized_data_by_provider: { provider1 => normalized_data },
                                         users_by_organization: { provider1 => { admin: 1, owner: 2, member: 3 } })
  end

  # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
  it 'renders the tab layout' do
    render

    expect(rendered).to have_css('ul#summary-tabs > li', count: 4)
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

  it 'renders info in the Jobs pane' do
    render

    expect(rendered).to have_css('table#jobs-table > tbody > tr > td > a', text: job_tracker_active.created_at)
    expect(rendered).to have_css('table#jobs-table > tbody > tr > td > a', text: job_tracker_attention.created_at)
  end

  it 'does not render the activity summary tabs on page 2 of uploads' do
    assign(:uploads, Kaminari.paginate_array(uploads1).page(2))
    expect(rendered).to have_no_css('ul#summary-tabs')
  end
end
