# frozen_string_literal: true

# Stored MARC dataset profiling data
class MarcProfile < ApplicationRecord
  belongs_to :upload
  belongs_to :blob, class_name: 'ActiveStorage::Blob'
end
