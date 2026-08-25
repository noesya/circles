class CreateInteractions < ActiveRecord::Migration[8.1]
  def change
    create_table :interactions, id: :uuid do |t|
      t.references :person, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.integer :kind, null: false
      t.datetime :occurred_at, null: false
      t.string :title
      t.text :description
      t.string :external_url
      t.string :source_id
      t.timestamps
    end
    add_index :interactions, :occurred_at
    add_index :interactions, [ :user_id, :source_id ], unique: true, where: "source_id IS NOT NULL"
  end
end
