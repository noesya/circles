class AddSourceToPeople < ActiveRecord::Migration[8.1]
  def change
    add_column :people, :source, :integer
  end
end
