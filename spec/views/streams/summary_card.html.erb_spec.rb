# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'streams/summary_card', type: :view do
  let(:organization) { create(:organization, name: 'Best University') }
  let(:stream) { create(:stream_with_uploads, organization: organization) }
  let(:user) { create(:user) }

  before do
    assign(:organization, organization)
    assign(:stream, stream)
    Upload.create!([
                     {
                       name: 'upload1',
                       stream: stream,
                       url: 'http://example.com/upload1.zip'
                     },
                     {
                       name: 'upload2',
                       stream: stream,
                       url: 'http://example.com/upload2.zip'
                     }
                   ])
    assign(:uploads, stream.uploads.active.order(created_at: :desc).page(params[:page]))
  end

  it 'displays Files info' do
    # pass local variable to partial
    render subject, stream: stream # rubocop:disable RSpec/NamedSubject

    expect(rendered).to include(number_with_delimiter(stream.files.size))
    expect(rendered).to include('Files')
  end

  it 'displays Total file size info' do
    render subject, stream: stream # rubocop:disable RSpec/NamedSubject

    expect(rendered).to include(number_to_human_size(stream.files.sum(:byte_size)))
    expect(rendered).to include('Total filesize')
  end

  it 'displays Records info' do
    render subject, stream: stream # rubocop:disable RSpec/NamedSubject

    expect(rendered).to include(number_with_delimiter(stream.statistic&.record_count || 0))
    expect(rendered).to include('Records')
  end

  it 'displays Unique records info' do
    render subject, stream: stream # rubocop:disable RSpec/NamedSubject

    expect(rendered).to include(number_with_delimiter(stream.statistic&.unique_record_count || 0))
    expect(rendered).to include('Unique records')
  end
end
