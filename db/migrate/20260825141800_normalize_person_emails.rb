class NormalizePersonEmails < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE person_emails SET value = LOWER(TRIM(value)) WHERE value IS NOT NULL"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
