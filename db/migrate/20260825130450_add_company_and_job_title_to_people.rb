class AddCompanyAndJobTitleToPeople < ActiveRecord::Migration[8.1]
  def change
    add_column :people, :company, :string
    add_column :people, :job_title, :string
  end
end
