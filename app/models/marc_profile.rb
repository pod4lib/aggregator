# frozen_string_literal: true

# Stored MARC dataset profiling data
class MarcProfile < ApplicationRecord
  belongs_to :upload, optional: true
  belongs_to :blob, class_name: 'ActiveStorage::Blob'
  attr_writer :count

  def count
    @count || blob.metadata['count']
  end

  def deep_merge!(blob_profile)
    sum = ->(_key, oldval, newval) { newval + oldval }

    self.count += blob_profile.count
    record_frequency.merge!(blob_profile.record_frequency, &sum)
    sampled_values.merge!(blob_profile.sampled_values, &sum)
    histogram_frequency.merge!(blob_profile.histogram_frequency) do |_key, oldval, newval|
      oldval.merge(newval, &sum)
    end

    self
  end
end
