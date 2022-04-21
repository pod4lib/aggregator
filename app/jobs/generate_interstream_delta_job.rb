# frozen_string_literal: true

##
# Background job to generate interstream delta between a stream and its predecessor
class GenerateInterstreamDeltaJob < ApplicationJob
	with_job_tracking
  
	def self.generate_interstream_delta_for_stream(stream)
		if (stream.is_a? Integer)
			stream = Stream.find_by_id(stream)
		end
		return if stream.nil?
		GenerateInterstreamDeltaJob.perform_later(stream)
	end
  
	# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
	def perform(stream)
		previous_stream = stream.default_stream_history.previous_stream_history.stream
		return if previous_stream.nil?
		
		current_stream_dump = stream.current_full_dump
		previous_stream_dump = previous_stream.current_full_dump

		return unless current_stream_dump and previous_stream_dump

		comparison_hash = {}
		additions = []
		previous_stream_reader = MarcRecordService.new(previous_stream_dump.marcxml.blob)
		previous_stream_reader.each_slice(100) do |batch|
			batch.each do |record|
				# Rails.logger.info(record.class)
				# Rails.logger.info(record)
				# Rails.logger.info(record['001'])
				# Rails.logger.info(record['001'].value) # This is what I want
				comparison_hash[record['001'].value] = 'record goes here'
			end
		end

		current_stream_reader = MarcRecordService.new(current_stream_dump.marcxml.blob)
		current_stream_reader.each_slice(100) do |batch|
			batch.each do |record|
				if comparison_hash.key?(record['001'].value)
					comparison_hash.delete(record['001'].value)
					Rails.logger.info("Found a record in both: delete from hash")
				else
					additions << record['001'].value
					Rails.logger.info("Found a record not in comparison hash: new addition")
				end
			end
		end

		deletions = comparison_hash.values

		#####
		# first		# second	# to-do
		# ------------------------------
		#	yes			yes			nothing
		#   no			yes			addition
		#	yes			no			deletion

		Rails.logger.info(comparison_hash.to_yaml)
		Rails.logger.info('additions')
		Rails.logger.info(additions)
		Rails.logger.info('deletions')
		Rails.logger.info(deletions)
	end
  end
  