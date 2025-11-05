# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::SummaryComponent, type: :component do
  subject(:rendered) { Capybara::Node::Simple.new(render_inline(described_class.new(uploads: uploads)).to_html) }

  let(:user) { create(:user) }
  let(:provider) { create(:organization, name: 'provider1') }
  let(:uploads_list) { create_list(:upload, 2, :multiple_files, stream: provider.default_stream) }

  let(:first_page_uploads)  { Kaminari.paginate_array(uploads_list).page(1) }
  let(:second_page_uploads) { Kaminari.paginate_array(uploads_list).page(2) }

  # rubocop:disable RSpec/AnyInstance
  before do
    allow_any_instance_of(ApplicationController).to receive(:current_ability).and_return(Ability.new(user))
  end
  # rubocop:enable RSpec/AnyInstance

  context 'with page 1 of uploads' do
    let(:uploads) { first_page_uploads }

    # rubocop:disable RSpec/MultipleExpectations
    it 'renders all summary tabs' do
      expect(rendered).to have_css('ul#summary-tabs > li', count: 3)
      expect(rendered).to have_css('div#summary-tabs-content > div#uploads-pane')
      expect(rendered).to have_css('div#summary-tabs-content > div#normalized-data-pane')
      expect(rendered).to have_css('div#summary-tabs-content > div#users-pane')
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'renders upload activity table with upload name and file name' do
      expect(rendered).to have_css('table#upload-activity > tbody > tr > td', text: uploads_list.first.name)
      expect(rendered).to have_css('table#upload-activity > tbody > tr > td',
                                   text: uploads_list.first.files.first.filename.to_s)
    end
  end

  context 'with page 2 of uploads' do
    let(:uploads) { second_page_uploads }

    it 'does not render the summary tabs' do
      expect(rendered).to have_no_css('ul#summary-tabs')
    end
  end
end
