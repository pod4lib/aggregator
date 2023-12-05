# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_footer' do
  it 'displays an accessibility message' do
    render

    expect(rendered).to have_link('report your accessibility issue')
  end
end
