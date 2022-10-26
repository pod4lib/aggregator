# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'pages/data' do
  it 'renders' do
    render
    assert_select 'h2', 'Guidelines for data consumers'
  end
end
