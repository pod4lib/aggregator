require 'rails_helper'

RSpec.describe 'uploads/show', type: :view do
  let(:organization) { FactoryBot.create(:organization) }

  before do
    @upload = assign(:upload, Upload.create!(
                                name: 'Name',
                                files: [],
                                stream_id: organization.default_stream.id
                              ))
    assign(:organization, organization)
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(//)
  end
end
