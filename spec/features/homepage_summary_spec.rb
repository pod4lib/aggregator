# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'homepage summary' do
  let(:provider) { create(:organization, name: 'Provider', provider: true) }
  let(:upload1) { create(:upload, :marc_xml, organization: provider, stream: provider.default_stream) }
  let(:upload2) { create(:upload, :marc21_multi_record, organization: provider, stream: provider.default_stream) }

  before do
    # a consumer org (shouldn't count towards provider total)
    create(:organization, name: 'Consumer', provider: false)

    # first upload has one record, second one has two. three total, two unique
    create(:marc_record, upload: upload1, file: upload1.files.first, marc001: '1')
    create(:marc_record, upload: upload2, file: upload2.files.first, marc001: '1')
    create(:marc_record, upload: upload2, file: upload2.files.first, marc001: '2')

    # run the statistics jobs so stats are available
    UpdateOrganizationStatisticsJob.perform_now(provider)

    visit '/'
  end

  it 'displays the total number of data providers' do
    expect(page).to have_content 'There is currently 1 data provider'
  end

  it 'displays the most recent provider that uploaded data' do
    expect(page).to have_content 'The most recent upload was made by Provider less than a minute ago'
  end

  it 'displays the total number of records and unique records in the aggregator' do
    expect(page).to have_content 'POD Aggregator currently holds a total of 3 records, of which 2 are unique'
  end

  context 'when logged in' do
    let(:user) { create(:user) }

    before do
      user.add_role :member, provider
      login_as(user, scope: :user)
      visit '/'
    end

    it 'displays the most recent time at which the org uploaded data' do
      expect(page).to have_content 'Most recent upload was less than a minute ago'
    end

    it 'displays the most recent files that the org uploaded' do
      expect(page).to have_content '12345.marcxml'
      expect(page).to have_content '9953670.marc'
    end

    it 'displays the processing status of any active jobs' do
      expect(page).to have_content '2 jobs active'
    end

    it 'displays the Provider home link' do
      expect(page).to have_link 'Provider home'
    end
  end

  context 'when not logged in' do
    before do
      visit '/'
    end

    it 'displays info for logging in' do
      expect(page).to have_content 'Already a POD user?'
      expect(page).to have_link 'Login'
    end

    it 'displays links to docs' do
      expect(page).to have_content 'Check out the POD wiki or contact pod-support@lists.stanford.edu'
    end
  end
end
