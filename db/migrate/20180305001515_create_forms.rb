class CreateForms < ActiveRecord::Migration[5.1]
  def change
    create_table :forms do |t|
      t.string :name
      t.date :filing_date
      t.string :filing_url
      t.integer :company_id
      t.integer :quarter
      t.integer :year

      t.timestamps
    end
    add_index :forms, :name
    add_index :forms, :filing_date
    add_index :forms, :filing_url
    add_index :forms, :company_id
    add_index :forms, :quarter
    add_index :forms, :year
  end
end
