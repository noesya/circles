class AddPersonToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :person, null: true, foreign_key: true, type: :uuid
  end
end
