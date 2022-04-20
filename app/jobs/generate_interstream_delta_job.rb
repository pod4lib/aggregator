# frozen_string_literal: true

##
# Background job to generate interstream delta between a stream and its predecessor
class GenerateInterstreamDeltaJob < ApplicationJob
	with_job_tracking
  
	def self.generate_interstream_delta_for_stream(stream)
		if (stream.is_a? Integer)
			stream = Stream.find(stream)
		end
		# default_stream_histories = stream.organization.default_stream_histories.all.count
		GenerateInterstreamDeltaJob.perform_later(stream)
	end
  
	# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
	def perform(stream)
		current_stream_history = stream.default_stream_history
		previous_stream_history = current_stream_history.previous_stream_history
	end
  end
  