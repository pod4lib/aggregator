# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'uploads/new', type: :view do
  let(:organization) { FactoryBot.create(:organization) }

  before do
    assign(:upload, Upload.new(
                      name: 'MyString',
                      files: ''
                    ))
    assign(:organization, organization)
  end

  it 'renders new upload form' do
    render

    assert_select 'form[action=?][method=?]', organization_uploads_path(organization), 'post' do
      assert_select 'input[name=?]', 'upload[name]'

      assert_select 'input[name=?]', 'upload[files][]'
    end
  end
end
