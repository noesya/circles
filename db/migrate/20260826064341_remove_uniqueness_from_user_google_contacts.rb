class RemoveUniquenessFromUserGoogleContacts < ActiveRecord::Migration[8.1]
  # Un resource_name Google peut légitimement pointer vers 2 Person
  # différentes (doublons de Person non fusionnés) : ça se règle via le
  # dédoublonnage (/people/:id/merge), pas en contraignant cette table.
  def change
    remove_index :user_google_contacts, [ :person_id, :user_id ]
    remove_index :user_google_contacts, [ :user_id, :resource_name ]
  end
end
