# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'uploads/new', type: :view do
  let(:organization) { FactoryBot.create(:organization) }
  let(:stream) { organization.default_stream }

  before do
    assign(:upload, Upload.new(
                      name: 'MyString'
                    ))
    assign(:organization, organization)
    without_partial_double_verification do
      allow(view).to receive(:current_stream).and_return(stream)
    end
  end

  it 'renders new upload form' do
    render

    assert_select 'form[action=?][method=?]', organization_uploads_path(organization), 'post' do
      assert_select 'input[name=?]', 'upload[name]'

      assert_select 'input[name=?]', 'upload[files][]'
    end
  end

  context 'with a non-default stream' do
    let(:stream) { organization.streams.create(name: 'abc') }

    it 'includes the stream parameter' do
      render

      assert_select 'form[action=?][method=?]', organization_uploads_path(organization), 'post' do
        assert_select 'input[name=?][value=?]', 'stream', stream.friendly_id
      end
    end
  end
end
