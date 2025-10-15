class AddOrganizationIdToMarcRecords < ActiveRecord::Migration[8.0]
  def change
    add_reference :marc_records, :organization, index: true

    reversible do |dir|
      dir.up do
        say_with_time 'Backfilling organization_id for existing MARC records' do
          MarcRecord.reset_column_information

          Upload.includes(:stream).find_each do |upload|
            upload.marc_records.update_all(organization_id: upload.stream.organization_id)
          end
        end
      end
    end
  end
end
