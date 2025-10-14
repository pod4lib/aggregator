class ReplaceMarcProfileForeignKey < ActiveRecord::Migration[8.0]
  def change
    if foreign_key_exists?(:marc_profiles, :uploads)
      remove_foreign_key :marc_profiles, :uploads
    end
  end
end
