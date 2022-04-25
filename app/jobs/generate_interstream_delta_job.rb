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

		return unless current_stream_dump && previous_stream_dump

		# compare full dump of full stream vs previous stream's full dump + its deltas

		# Get full dump and its records
		comparison_hash = {}
		updates_and_additions = []
		previous_stream_reader = MarcRecordService.new(previous_stream_dump.marcxml.blob)
		previous_stream_reader.each_slice(100) do |batch|
			batch.each do |record|
				comparison_hash[record['001'].value] = record
			end
		end

		# Then one-by-one adjust according to each delta from oldest to newest
		previous_stream_deltas = previous_stream_dump.deltas.order(created_at: :asc)
		previous_stream_deltas.each do |delta|
			if delta.marcxml.blob
				delta_reader = MarcRecordService.new(delta.marcxml.blob)
				delta_reader.each_slice(100) do |batch|
					batch.each do |record|
						comparison_hash[record['001'].value] = record
					end
				end
			end
			if delta.deletes.blob
				delta.deletes.blob.open do |tempfile|
					delete_ids = tempfile.read.split
					delete_ids.each do |delete_id|
						if comparison_hash.key?(delete_id)
							comparison_hash.delete(delete_id)
						end
					end
				end
			end
		end

		current_stream_reader = MarcRecordService.new(current_stream_dump.marcxml.blob)
		records_in_second_dump = 0
		current_stream_reader.each_slice(100) do |batch|
			batch.each do |record|
				records_in_second_dump = records_in_second_dump + 1
				if comparison_hash.key?(record['001'].value) && comparison_hash[record['001'].value] == record
					# Matching record that has not been updated
					# per the code in the marc record class: https://github.com/ruby-marc/ruby-marc/blob/master/lib/marc/record.rb
					# == appears to be a safe way to compare MARC::Record objects
					comparison_hash.delete(record['001'].value)
					Rails.logger.info("Found an identifcal record in both dumps: delete from hash")
				elsif comparison_hash.key?(record['001'].value)
					# Matching records that have been updated, are added to updates_and_additions and removed from comparison
					updates_and_additions << record
					comparison_hash.delete(record['001'].value)
					Rails.logger.info("Found an updated record in new dump: new addition")
				else
					#########
					#########
					# This db query doesn't seem reliable as there can be more than one version of the record in the db
					# I think we need to get the latest one among all uploads for that stream that's are included in the dump
					# new_record = MarcRecord.where('marc001': record['001'].value)
					# updates_and_additions << new_record
					#########
					#########
					updates_and_additions << record
					Rails.logger.info("Found a record not in comparison hash: new addition")
				end
			end
		end

		deletions = comparison_hash.keys

		#####
		# first		# second	# to-do
		# ------------------------------
		#	yes			yes			if updated: add to updates_and_additions
		#	yes			yes			if not updated: remove from hash
		#   no			yes			updates_and_additions
		#	yes			no			deletion

		# Rails.logger.info("COMPARISON HASH")
		# Rails.logger.info(comparison_hash.to_yaml)
		Rails.logger.info('updates_and_additions')
		Rails.logger.info(updates_and_additions.count)
		# Updates/Additions are currently of class MARC::Record
		# Writer seems to use MarcRecord
		Rails.logger.info('deletions')
		# Deletions are strings
		Rails.logger.info(deletions)

		# base_name = "#{stream.organization.slug}-#{Time.zone.today}-delta-#{previous_stream.id}-#{stream.id}"
		# writer = MarcRecordWriterService.new(base_name)
		# begin
		# 	updates_and_additions.each do |record|
		# 		# This method expects MarcRecord but additions/updates are currently MARC::Record
		# 		writer.write_marc_record(record)
		# 	end

		# 	# writer.finalize

		# 	# writer.files.each do |as, file|
		# 	# 	full_dump.public_send(as).attach(io: File.open(file), filename: human_readable_filename(base_name, as))
		# 	# end

		# 	# full_dump.save!

		# 	# GenerateDeltaDumpJob.perform_later(organization)
		# 	# ensure
		# 	# writer.close
		# 	# writer.unlink
		# 	# end
		# end

		# WIll need to generate both marcxml and binary
		# Try using the ruby marc gem to write those ^
	end
end
  