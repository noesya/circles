class CreatePersonEmails < ActiveRecord::Migration[8.1]
  def change
    create_table :person_emails, id: :uuid do |t|
      t.string :value
      t.references :person, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
