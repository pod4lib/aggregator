# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_flash_msg.html.erb' do
  context 'with an alert flash' do
    before do
      flash[:alert] = 'This is an alert!'
    end

    it 'displays an alert' do
      render

      expect(rendered).to include 'This is an alert!'
    end
  end

  context 'with multiple alert flashes' do
    before do
      flash[:alert] = [
        'This is an alert!',
        'This is another alert!'
      ]
    end

    it 'displays an alert' do
      render

      expect(rendered).to include('This is an alert!')
        .and(include('This is another alert!'))
    end
  end

  context 'with different types of flashes' do
    before do
      flash[:alert] = 'This is an alert!'
      flash[:success] = 'This is a success'
      flash[:notice] = 'This is a notice'
      flash[:error] = 'This is an error'
    end

    it 'displays multiple types of notices' do
      render

      expect(rendered).to include('This is an alert!')
        .and(include('This is a success'))
        .and(include('This is a notice'))
        .and(include('This is an error'))
    end
  end
end
