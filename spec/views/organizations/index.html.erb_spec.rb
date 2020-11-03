# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'organizations/index', type: :view do
  before do
    assign(:organizations, [FactoryBot.create(:organization, name: 'Name1'), FactoryBot.create(:organization)])
  end

  it 'renders a list of organizations' do
    render
    assert_select 'tr>td', text: 'Name1'.to_s
  end
end
