# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'organizations/index', type: :view do
  before do
    assign(:organizations, [create(:organization, name: 'Name1'), create(:organization)])
  end

  it 'renders a list of organizations' do
    render
    assert_select 'tr>td', text: 'Name1'.to_s
  end
end
