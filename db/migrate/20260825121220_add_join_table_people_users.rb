class AddJoinTablePeopleUsers < ActiveRecord::Migration[8.1]
  def change
    create_join_table :people, :users, column_options: {type: :uuid} do |t|
      t.index [:user_id, :person_id]
    end
  end
end
