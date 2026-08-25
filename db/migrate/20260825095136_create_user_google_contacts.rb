class CreateUserGoogleContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :user_google_contacts, id: :uuid do |t|
      t.references :person, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :resource_name, null: false
      t.timestamps
    end
    add_index :user_google_contacts, [ :person_id, :user_id ], unique: true
    add_index :user_google_contacts, [ :user_id, :resource_name ], unique: true
  end
end
