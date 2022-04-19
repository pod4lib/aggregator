# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'streams/header', type: :view do
  let(:organization) { create(:organization, name: 'Best University') }
  let(:stream) { create(:stream_with_uploads, organization: organization) }
  let(:user) { create(:user) }

  before do
    assign(:organization, organization)
    assign(:stream, stream)
  end

  it 'displays the default stream name' do
    # pass local variable to partial
    render subject, stream: stream # rubocop:disable RSpec/NamedSubject

    expect(rendered).to include(stream.display_name)
  end

  it 'displays the Manage streams link' do
    allow(view).to receive(:can?).and_return(true)
    render subject, stream: stream # rubocop:disable RSpec/NamedSubject

    expect(rendered).to have_link 'Manage streams'
  end

  it 'displays the Upload file button' do
    allow(view).to receive(:can?).and_return(true)
    render subject, stream: stream # rubocop:disable RSpec/NamedSubject

    expect(rendered).to have_link 'Upload file'
  end

  it 'displays the Re-analyze button' do
    allow(view).to receive(:can?).and_return(true)
    render subject, stream: stream # rubocop:disable RSpec/NamedSubject

    expect(rendered).to have_link 'Re-analyze'
  end

  it 'displays the count of streams in the org' do
    allow(view).to receive(:can?).and_return(true)
    render subject, stream: stream # rubocop:disable RSpec/NamedSubject

    expect(rendered).to include(stream.organization.streams.active.count.to_s)
  end
end
