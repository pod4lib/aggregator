# frozen_string_literal: true

# :nodoc:
class DataController < ApplicationController
	load_and_authorize_resource :organizations
	
	def index; end
end