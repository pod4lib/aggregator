class CreateContactEmails < ActiveRecord::Migration[6.0]
  def change
    create_table :contact_emails do |t|
      t.string :email
      t.references :organization, null: false, foreign_key: true
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at

      t.timestamps
    end
    add_index :contact_emails, :confirmation_token, unique: true
  end
end
