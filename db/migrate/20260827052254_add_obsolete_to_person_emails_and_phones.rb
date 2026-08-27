class AddObsoleteToPersonEmailsAndPhones < ActiveRecord::Migration[8.1]
  def change
    add_column :person_emails, :obsolete, :boolean, default: false, null: false
    add_column :person_phones, :obsolete, :boolean, default: false, null: false
  end
end
