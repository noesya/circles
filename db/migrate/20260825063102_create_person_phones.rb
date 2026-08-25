class CreatePersonPhones < ActiveRecord::Migration[8.1]
  def change
    create_table :person_phones, id: :uuid do |t|
      t.string :canonical
      t.string :value
      t.references :person, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
