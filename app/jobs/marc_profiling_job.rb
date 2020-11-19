# frozen_string_literal: true

# Extract MarcRecord instances from an upload
class MarcProfilingJob < ApplicationJob
  queue_as :default

  # Adapted from https://t-a-w.blogspot.com/2010/07/random-sampling-or-processing-data.html
  class Sample
    include Enumerable

    def initialize(wanted, total_size)
      @wanted = wanted
      @size_so_far = 0
      @total_size = total_size
      @sample = []
    end

    def add(item)
      @size_so_far += 1
      j = @wanted > @sample.size ? @sample.size : rand(@total_size)
      @sample[j] = [@size_so_far, item] if @wanted > j
    end

    def each
      @sample.sort.each { |_idx, it| yield(it) }
    end
  end

  # Tally up some statistics about the MARC records in the file:
  #   - how many times a field/subfield is used
  #   - how many records have a field/subfield
  #   - how many times a field/subfield is used in a record
  # and collect a sampling of field/subfield occurences.
  # rubocop:disable all (Ha!)
  def perform(blob, count: nil, sample_size: 25)
    count ||= blob.metadata['count']

    return unless count

    sampled_values = Hash.new { |hash, key| hash[key] = Sample.new(sample_size, count) }
    instance_frequency = Hash.new { |hash, key| hash[key] = 0 }
    record_frequency = Hash.new { |hash, key| hash[key] = 0 }
    histogram_frequency = Hash.new { |hash, key| hash[key] = Hash.new { |h, k| h[k] = 0 } }

    marc_record_service(blob).each do |record|
      record_stats = Hash.new { |hash, key| hash[key] = 0 }

      record.fields.each do |field|
        record_frequency[field.tag] += 1 if record_stats[field.tag].zero?
        record_stats[field.tag] += 1

        instance_frequency[field.tag] += 1

        if field.is_a? MARC::ControlField
          sampled_values[field.tag].add(field.value)
        else
          sampled_values[field.tag].add(field.to_s)
          field.each do |subfield|
            key = "#{field.tag}$#{subfield.code}"
            sampled_values[key].add(subfield.value)

            record_frequency[key] += 1 if record_stats[key].zero?
            record_stats[key] += 1

            instance_frequency[key] += 1
          end
        end
      end

      record_stats.each do |key, value|
        histogram_frequency[key][value] += 1
      end
    end

    MarcProfile.create(
      blob: blob,
      upload: blob.attachments.first.record,
      field_frequency: instance_frequency,
      record_frequency: record_frequency,
      histogram_frequency: histogram_frequency,
      sampled_values: sampled_values.transform_values(&:to_a)
    )
  end
  # rubocop:enable all

  def marc_record_service(blob)
    MarcRecordService.new(blob)
  end
end
