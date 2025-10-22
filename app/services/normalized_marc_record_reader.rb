# frozen_string_literal: true

# Utility class for reading marc records out of a set of uploads
# and filtering any obsolete records so we only get the latest
# version of each record.
class NormalizedMarcRecordReader
  include Enumerable

  attr_reader :uploads, :thread_pool_size, :conditions

  # @param [Array<Upload>] uploads
  def initialize(uploads, thread_pool_size: 10, augment_marc: true, conditions: {})
    @uploads = uploads
    @thread_pool_size = thread_pool_size
    @augment_marc = augment_marc
    @conditions = conditions
  end

  # @yield [MarcRecord]
  def each(...)
    pool = Concurrent::FixedThreadPool.new(thread_pool_size) if eagerly_augment_marc?

    current_marc_record_ids.each_slice(200) do |slice|
      records = MarcRecord.includes(:upload, :stream, :organization).find(slice)

      if eagerly_augment_marc?
        # do a little pre-processing to pre-generated the augmented MARC.
        # this is done in a thread pool for a marginal performance boost
        # (10-15%).
        records.each do |record|
          pool.post { record.augmented_marc }
        rescue StandardError
          nil
        end
      end

      records.each(...)
    end

    pool&.shutdown
  end

  # Return the full list of MarcRecord id values to include in the dump.
  # Note: ideally we'd be able to iterate through that list, but e.g. #find_each
  #   does not support custom ordering (which we need in order to ensure we identify
  #   the most recent record for each 001)
  # @return [Array<Integer>] the list of MarcRecord id values
  def current_marc_record_ids
    return __pgsql_current_marc_record_ids if using_postgres?
    return to_enum(:current_marc_record_ids) unless block_given?

    # But for other databases, we'll have to do it ourselves.
    query = MarcRecord.select(:marc001, :id)
                      .where(upload: uploads, **conditions)
                      .order(marc001: :asc, file_id: :desc, id: :asc)
    query.each.chunk(&:marc001).each { |_key, records| yield records.first.id }
  end

  private

  def using_postgres?
    defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) &&
      ActiveRecord::Base.connection.instance_of?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
  end

  def __pgsql_current_marc_record_ids
    # Postgres has 'SELECT DISTINCT ON', so we can have the database de-dupe marc records with the same 001
    # and return the most recent
    MarcRecord.select('DISTINCT ON (marc001) marc_records.id')
              .where(upload: uploads, **conditions)
              .order(:marc001, file_id: :desc, id: :asc).ids
  end

  def eagerly_augment_marc?
    @augment_marc
  end
end
