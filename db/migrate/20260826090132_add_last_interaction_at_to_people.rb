class AddLastInteractionAtToPeople < ActiveRecord::Migration[8.1]
  def change
    add_column :people, :last_interaction_at, :datetime
  end
end
