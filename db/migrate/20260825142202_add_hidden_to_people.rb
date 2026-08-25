class AddHiddenToPeople < ActiveRecord::Migration[8.1]
  def change
    add_column :people, :hidden, :boolean, null: false, default: false
  end
end
