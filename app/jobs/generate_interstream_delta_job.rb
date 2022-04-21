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
				# Rails.logger.info(record['001'].value) # This is what I want
				comparison_hash[record['001'].value] = record
			end
		end

		current_stream_reader = MarcRecordService.new(current_stream_dump.marcxml.blob)
		current_stream_reader.each_slice(100) do |batch|
			batch.each do |record|
				if comparison_hash.key?(record['001'].value)
					comparison_hash.delete(record['001'].value)
					Rails.logger.info("Found a record in both: delete from hash")
				else
					additions << record
					Rails.logger.info("Found a record not in comparison hash: new addition")
				end
			end
		end

		deletions = comparison_hash.keys

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

		base_name = "#{stream.organization.slug}-#{Time.zone.today}-delta-#{previous_stream.id}-#{stream.id}"
	# 	writer = MarcRecordWriterService.new(base_name)
	# 	now = Time.zone.now
	# 	full_dump = stream.normalized_dumps.build(last_full_dump_at: now, last_delta_dump_at: now)
	# 	begin
	# 		additions.each do |record|
	# 			# In a full dump, we can omit the deletes
	
	# 			writer.write_marc_record(record)
	# 		end
	  
	# 		writer.finalize
	  
	# 		writer.files.each do |as, file|
	# 		  full_dump.public_send(as).attach(io: File.open(file), filename: human_readable_filename(base_name, as))
	# 		end
	  
	# 		full_dump.save!
	  
	# 	ensure
	# 		writer.close
	# 		writer.unlink
	# 	end
	# end

	# def human_readable_filename(base_name, file_type)
	# 	as = case file_type
	# 		 when :deletes
	# 		   'deletes.del.txt'
	# 		 when :marc21
	# 		   'marc21.mrc.gz'
	# 		 when :marcxml
	# 		   'marcxml.xml.gz'
	# 		 when :errata
	# 		   'errata.gz'
	# 		 else
	# 		   as
	# 		 end
	
	# 	"#{base_name}-#{as}"
	end
end
  