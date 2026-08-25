class FixInteractionsSourceIdUniqueness < ActiveRecord::Migration[8.1]
  def change
    remove_index :interactions, [ :user_id, :source_id ]
    add_index :interactions, [ :user_id, :person_id, :source_id ], unique: true, where: "source_id IS NOT NULL"
  end
end
