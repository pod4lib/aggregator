# frozen_string_literal: true

module Types
  # Graphql query support for retrieving marc records, filtered by fields in the record
  module MarcRecordsQuery
    def with_limit(limit, what, **args, &block)
      return send(what, **args, &block) unless limit

      i = 0

      send(what, **args).each do |record|
        yield record
        i += 1
        break if i >= limit
      end
    end

    def each_record(organization = nil, &block)
      return to_enum(:each_record, organization) unless block

      l = Array(organization) if organization
      l ||= Organization.accessible_by(current_ability)

      l.each do |org|
        org.default_stream.uploads.find_each do |upload|
          upload.each_marc_record_metadata(&block)
        end
      end
    end

    def filter_records(filter: nil, organization: nil, &block)
      return to_enum(:filter_records, filter: filter, organization: organization) unless block

      return each_record(organization, &block) unless filter

      each_record(organization) do |record|
        yield record if filter.all? { |f| evaluate_marcspec_filter(record.marc, f) }
      end
    end

    def evaluate_marcspec_filter(record, filter)
      if filter.include?('$')
        field, subfield = filter.split('$', 2)

        matching_fields(field).any? do |f|
          f[subfield]
        end
      elsif filter.starts_with? 'LDR'
        record.leader
      elsif filter.match?(/^\d{3}[a-z]$/)
        field = filter[0..2]
        subfield = filter[3]
        evaluate_marcspec_filter(record, "#{field}$#{subfield}")
      else
        matching_fields(filter).any?
      end
    end

    def matching_fields(record, field)
      return record.fields(filter) if field.match?(/[a-z0-9A-Z]{3}/)
      return to_enum(:matching_fields, record, field) unless block_given?

      field_as_regex = Regexp.new(field)

      record.fields.each do |f|
        yield f if f.tag.match?(field_as_regex)
      end
    end
  end
end
